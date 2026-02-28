/**
 * @name Resources exhaustion from deep object traversal
 * @description Processing user-controlled object hierarchies inefficiently can lead to denial of service.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id js/resource-exhaustion-from-deep-object-traversal
 * @tags security
 *       external/cwe/cwe-400
 */

import javascript
import semmle.javascript.security.dataflow.DeepObjectResourceExhaustionQuery
import DataFlow::DeduplicatePathGraph<DeepObjectResourceExhaustionFlow::PathNode, DeepObjectResourceExhaustionFlow::PathGraph>

from PathNode source, PathNode sink, DataFlow::Node link, string reason
where 
  DeepObjectResourceExhaustionFlow::flowPath(source.getAnOriginalPathNode(),
    sink.getAnOriginalPathNode()) and
  sink.getNode().(Sink).hasReason(link, reason)
select
  sink,
  source,
  sink,
  "Denial of service caused by processing $@ with $@ (source at " +
    source.getNode().getFile().getRelativePath() + ":" +
    source.getNode().getLocation().getStartLine().toString() + ")." + "with reason: " + reason,

  sink.getNode().getFile().getRelativePath(),
  sink.getNode().getLocation().getStartLine(),
  sink.getNode().getLocation().getEndLine(),

  source.getNode().getFile().getRelativePath(),
  source.getNode().getLocation().getStartLine(),
  source.getNode().getLocation().getEndLine()

// Explaination about result file (csv):
// col 1: the node where the sink is located, which is the point of vulnerability.
// col 2: the source node
// col 3: the sink node, which is the point where the vulnerability can be exploited
// col 4: a message describing the vulnerability, including the source location for context.
// col 5-7: details about the sink's location (file path, start line, end line).
// col 8-10: details about the source's location (file path, start line, end line).

// Note: About the warning, I dont want to follow the format of the required template as its hard to read and understand, 
// so I will just write the message in my way but from col 1 - 4, I will follow the original template. So just ignore the warning please :>

// Expected output: "sink", "source", "sink", "message", "sink file path", "sink start line", "sink end line", "source file path", "source start line", "source end line"

// If encountering permssion issue, please run "chmod 644 {path_to_csv_file}"

// Why using DataFlow::DeduplicatePathGraph?
// Because this kind of vulnerability can produce many paths and create duplicated results and also noisy outputs
// So using this would help to deduplicate the paths and make the results more concise and easier to understand or in other words "Take the original flow graph, but collapse equivalent path variants into one clean path."
