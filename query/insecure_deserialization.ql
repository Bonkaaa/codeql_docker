/**
 * @name Deserialization of user-controlled data
 * @description Deserializing user-controlled data may allow attackers to
 *              execute arbitrary code.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 9.8
 * @precision high
 * @id js/unsafe-deserialization
 * @tags security
 *       external/cwe/cwe-502
 */

import javascript
import semmle.javascript.security.dataflow.UnsafeDeserializationQuery
import UnsafeDeserializationFlow::PathGraph

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(),
  "user-provided value"

// import javascript
// import semmle.javascript.security.dataflow.UnsafeDeserializationQuery
// import UnsafeDeserializationFlow::PathGraph

// from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
// where UnsafeDeserializationFlow::flowPath(source, sink)
// select 
//   sink.getNode(),                
//   source,                       
//   sink,                                         
//   "Unsafe deserialization depends on a $@. (source at " +
//     source.getNode().getFile().getRelativePath() + ":" +
//     source.getNode().getLocation().getStartLine().toString() + ").",

//   sink.getNode().getFile().getRelativePath(),
//   sink.getNode().getLocation().getStartLine(),
//   sink.getNode().getLocation().getEndLine(),
  
//   source.getNode().getFile().getRelativePath(),
//   source.getNode().getLocation().getStartLine(),
//   source.getNode().getLocation().getEndLine()

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

// If encountering permssion issue, please run "chmod 644 {path_to_csv_file}"

// TESTING SHOWS NO RESULT, WILL INVESTIGATE LATER