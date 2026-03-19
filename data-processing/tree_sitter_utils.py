from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Tuple, Dict, Any


from tree_sitter import Parser, Language
import tree_sitter_javascript as tsjavascript


@dataclass(frozen=True)
class Span:
    """
    Line/column span pointing to a region of JS source code.

    Conventions:
      - columns are 0-based (as you said)
      - lines_are_1_based controls whether start_line/end_line are 1-based (common in datasets)
    """
    start_line: int
    start_col: int
    end_line: int
    end_col: int


# JS function-ish node types in tree-sitter-javascript.
# Notes:
# - function_declaration: `function foo() {}`
# - function_expression: `const x = function foo() {}`
# - arrow_function: `() => {}`
# - method_definition: `class A { foo() {} }`
# - generator_function(_declaration/_expression): `function* foo() {}` / `const x = function*() {}`
JS_FUNC_NODE_TYPES = {
    "function_declaration",
    "function_expression",
    "arrow_function",
    "method_definition",
    "generator_function_declaration",
    "generator_function",
    "generator_function_expression",
}


def _point_leq(a: Tuple[int, int], b: Tuple[int, int]) -> bool:
    """Return True if point a <= point b (lexicographic by row then col)."""
    return a[0] < b[0] or (a[0] == b[0] and a[1] <= b[1])


def _span_contains(
    node_start: Tuple[int, int],
    node_end: Tuple[int, int],
    target_start: Tuple[int, int],
    target_end: Tuple[int, int],
) -> bool:
    """Return True if [target_start, target_end] is fully inside [node_start, node_end]."""
    return _point_leq(node_start, target_start) and _point_leq(target_end, node_end)


def _find_smallest_enclosing_js_function(root, target_start, target_end):
    """
    Walk the tree and return the smallest (innermost) JS function-like node
    whose range fully contains the target span.
    """
    best = None

    def visit(n):
        nonlocal best
        ns = (n.start_point[0], n.start_point[1])  # (row, col) both 0-based
        ne = (n.end_point[0], n.end_point[1])

        if _span_contains(ns, ne, target_start, target_end):
            if n.type in JS_FUNC_NODE_TYPES:
                if best is None or (n.end_byte - n.start_byte) < (best.end_byte - best.start_byte):
                    best = n

            # Recurse to find a smaller enclosing function, if any
            for ch in n.children:
                visit(ch)

    visit(root)
    return best


def _decode_slice(src: bytes, start: int, end: int) -> str:
    return src[start:end].decode("utf-8", errors="replace")


def _extract_js_function_name(node, src: bytes) -> Optional[str]:
    """
    Best-effort: return a JS function/method name if available.

    - function_declaration / function_expression may have field 'name'
    - method_definition usually has field 'name'
    - arrow_function has no name by itself (name is typically from the parent assignment)
    """
    name_node = node.child_by_field_name("name")
    if name_node is None:
        return None
    return _decode_slice(src, name_node.start_byte, name_node.end_byte)


def extract_enclosing_js_function(
    source: str | bytes,
    span: Span,
    *,
    lines_are_1_based: bool = True,
) -> Dict[str, Any]:
    """
    Extract the *enclosing* JS function for a given span.

    Parameters
    ----------
    source:
        Either:
          - a path to a JS file (str), OR
          - raw JS content (bytes)
        (If you truly have only a snippet, you can pass bytes directly; parsing may fail
         if the snippet isn't valid JS on its own.)
    span:
        Span(start_line,start_col,end_line,end_col) with 0-based columns.
    lines_are_1_based:
        Set True if your dataset line numbers are 1-based.

    Returns
    -------
    dict with:
      - found: bool
      - name: Optional[str] (None for anonymous/arrow functions)
      - node_type: str
      - start_point / end_point: (row,col) 0-based
      - source: function source text
    """
    if isinstance(source, (str, Path)):
        src_bytes = Path(source).read_bytes()
    else:
        src_bytes = source


    JS_LANGUAGE = Language(tsjavascript.language())
    parser = Parser(JS_LANGUAGE)
    tree = parser.parse(src_bytes)
    root = tree.root_node

    start_row = span.start_line - 1 if lines_are_1_based else span.start_line
    end_row = span.end_line - 1 if lines_are_1_based else span.end_line

    target_start = (start_row, span.start_col)
    target_end = (end_row, span.end_col)

    fn = _find_smallest_enclosing_js_function(root, target_start, target_end)
    if fn is None:
        return {"found": False, "reason": "No enclosing JS function node found"}

    return {
        "found": True,
        "name": _extract_js_function_name(fn, src_bytes),
        "node_type": fn.type,
        "start_point": fn.start_point,  # (row,col) 0-based
        "end_point": fn.end_point,      # (row,col) 0-based
        "source": _decode_slice(src_bytes, fn.start_byte, fn.end_byte),
    }

if __name__ == "__main__":
    # Example usage
    example_code = """
    function greet(name) {
        console.log("Hello, " + name);
    }
    """
    span = Span(start_line=2, start_col=15, end_line=2, end_col=20)  # points to "name" in console.log
    result = extract_enclosing_js_function(example_code.encode("utf-8"), span)
    print(result)