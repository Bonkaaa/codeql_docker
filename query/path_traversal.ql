/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access
 *              unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id js/path-injection
 * @tags security
 *       external/cwe/cwe-022
 *       external/cwe/cwe-023
 *       external/cwe/cwe-036
 *       external/cwe/cwe-073
 *       external/cwe/cwe-099
 */

import javascript
import semmle.javascript.security.dataflow.TaintedPathQuery
import DataFlow::DeduplicatePathGraph<TaintedPathFlow::PathNode, TaintedPathFlow::PathGraph>

from PathNode source, PathNode sink
where TaintedPathFlow::flowPath(source.getAnOriginalPathNode(), sink.getAnOriginalPathNode())
select 
  sink.getNode(),                
  source,                       
  sink,                                         
  "This path depends on $@ (source at " +
    source.getNode().getFile().getRelativePath() + ":" +
    source.getNode().getLocation().getStartLine().toString() + ").",

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

// Expected output:
// primary,source_node,sink_node,message,sink_file,sink_start_line,sink_end_line,source_file,source_start_line,source_end_line
// "ROOT + filePath","req.url","ROOT + filePath","This path depends on $@ (source at PathTraversal.js:8).","PathTraversal.js",11,11,"PathTraversal.js",8,8


// If encountering permssion issue, please run "chmod 644 {path_to_csv_file}"
