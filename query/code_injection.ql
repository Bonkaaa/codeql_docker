/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user arbitrary
 *              code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id js/code-injection
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

import javascript
import semmle.javascript.security.dataflow.CodeInjectionQuery
import CodeInjectionFlow::PathGraph

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink)
select 
  sink.getNode(),                
  source,                       
  sink,                                         
  sink.getNode().(Sink).getMessagePrefix() +
    " depends on $@ (source at " +
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
// primary,sourcenode,sinknode,message,sink_file,sink_start_line,sink_end_line,source_file,source_start_line,source_end_line
// "documen ... t="")+8)","documen ... on.href","documen ... t="")+8)","This code execution depends on $@ (source at CodeInjection.js:1).","CodeInjection.js",1,1,"CodeInjection.js",1,1

// If encountering permssion issue, please run "chmod 644 {path_to_csv_file}"