from collections import defaultdict
from pathlib import Path
import pandas as pd
from tree_sitter_utils import Span, extract_enclosing_js_function
import re

def add_vulnerable_function_to_df(
    df: pd.DataFrame,
    *,
    path_col: str = "file_path",
    start_line_col: str = "start_line",
    start_col_col: str = "start_column",
    end_line_col: str = "end_line",
    end_col_col: str = "end_column",
    lines_are_1_based: bool = False, 
):
    out = df.copy()

    def _one_row(row):
        span = Span(
            start_line=row[start_line_col],
            start_col=row[start_col_col],
            end_line=row[end_line_col],
            end_col=row[end_col_col],
        )

        try:
            res = extract_enclosing_js_function(
                row[path_col],
                span,
                lines_are_1_based=lines_are_1_based,
            )

        except Exception as e:
            return None
        
        if not res.get("found"):
            return None
        
        return res.get("name")
    
    out["vulnerable_function"] = out.apply(_one_row, axis=1)
    return out

def normalize_stage_in_path(s: str):
    return re.sub(r"(?<=/)(before|after)(?=/)", "STAGE", s)

def count_bugs(
    before: pd.DataFrame,
    after: pd.DataFrame,
    *,
    tol_lines: int = 2,
    key_cols: list[str] = ["path_norm", "start_column", "end_column"],
    func_col: str = "vulnerable_function",
    start_line_col: str = "start_line",
    end_line_col: str = "end_line",
) -> tuple[int, int, int]:
    """
    Count bugs in both / only-before / only-after allowing ±tol_lines drift in line numbers.

    A before-row and after-row are considered the same bug if:
      - they match exactly on `key_cols`
      - abs(start_line_before - start_line_after) <= tol_lines
      - abs(end_line_before - end_line_after) <= tol_lines
    """

    b = before.copy()
    a = after.copy()

    # Work on unique rows (so counts are "unique bugs" like your original)
    b = b[key_cols + [func_col, start_line_col, end_line_col]].drop_duplicates().reset_index(drop=True)
    a = a[key_cols + [func_col, start_line_col, end_line_col]].drop_duplicates().reset_index(drop=True)

    # Add ids so we can count matched bugs 1-to-1 (unique)
    b = b.reset_index(names="before_id")
    a = a.reset_index(names="after_id")

    # Candidate pairs: exact match on non-line keys
    cand = a.merge(b, on=key_cols, how="left", suffixes=("_after", "_before"))

    # Compute diffs (NaN if no candidate before row)
    cand["start_diff"] = (cand[f"{start_line_col}_after"] - cand[f"{start_line_col}_before"]).abs()
    cand["end_diff"]   = (cand[f"{end_line_col}_after"]   - cand[f"{end_line_col}_before"]).abs()

    # A candidate pair matches if within tolerance
    cand["is_match"] = (cand["start_diff"] <= tol_lines) & (cand["end_diff"] <= tol_lines)

    # Which after rows have at least one matching before row?
    after_has_match = cand.groupby("after_id")["is_match"].any()
    after_has_match = after_has_match.reindex(a["after_id"], fill_value=False)

    # Which before rows have at least one matching after row?
    before_has_match = cand[cand["is_match"]].groupby("before_id").size()
    before_has_match = before_has_match.reindex(b["before_id"], fill_value=0) > 0

    # Count bug change: same function but line diffs exceed tol
    a_remaining = a.loc[~after_has_match].copy()

    cand_func = a_remaining.merge(
        b[["before_id", func_col, start_line_col, end_line_col]],
        on=func_col,
        how="left",
        suffixes=("_after", "_before"),
    )

    cand_func["start_diff"] = (cand_func[f"{start_line_col}_after"] - cand_func[f"{start_line_col}_before"]).abs()
    cand_func["end_diff"]   = (cand_func[f"{end_line_col}_after"]   - cand_func[f"{end_line_col}_before"]).abs()

    cand_func["is_bug_change"] = (cand_func["start_diff"] > tol_lines) | (cand_func["end_diff"] > tol_lines)

    after_has_change = cand_func.groupby("after_id")["is_bug_change"].any()
    after_has_change = after_has_change.reindex(a_remaining["after_id"], fill_value=False)

    before_has_change = cand_func.loc[cand_func["is_bug_change"]].groupby("before_id").size()
    before_has_change = before_has_change.reindex(b["before_id"], fill_value=0) > 0


    # number_of_bugs_in_both = int(after_has_match.sum())
    # number_of_bugs_changed = int(after_has_change.sum())

    # number_of_bugs_only_in_after = int((~after_has_match & ~after_has_change).sum())
    # number_of_bugs_only_in_before = int((~before_has_match & ~before_has_change).sum())

    # return number_of_bugs_in_both, number_of_bugs_only_in_before, number_of_bugs_only_in_after, number_of_bugs_changed

    number_in_both = int(after_has_match.sum())
    number_bug_change = int(after_has_change.sum())
    number_only_in_after = int(len(a) - number_in_both - number_bug_change)

    # BEFORE rows are only_before if they are neither same nor change
    before_accounted = before_has_match | before_has_change
    number_only_in_before = int((~before_accounted).sum())

    return number_in_both, number_only_in_before, number_only_in_after, number_bug_change

def count_bugs_per_CVE(
    df_before: pd.DataFrame,
    df_after: pd.DataFrame,
    *,
    tol_lines: int = 3,
):
    cves = sorted(set(df_before["CVE"]) | set(df_after["CVE"]))

    rows = []

    for cve in cves:
        before = df_before[df_before["CVE"] == cve]
        after = df_after[df_after["CVE"] == cve]

        both, only_before, only_after, bugs_changed = count_bugs(before, after, tol_lines=tol_lines)

        rows.append({
            "CVE": cve,
            "both": both,
            "only_before": only_before,
            "only_after": only_after,
            "bugs_changed": bugs_changed,
        })

    return pd.DataFrame(rows).sort_values(["both", "only_before", "only_after", "bugs_changed"], ascending=False).reset_index(drop=True)



def add_CVE_from_path(df: pd.DataFrame, path_col: str = "file_path"):
    out = df.copy()
    out["CVE"] = out[path_col].str.strip("/").str.split("/").str[2]
    return out