/**
 * @name Prototype-polluting assignment
 * @description Modifying an object obtained via a user-controlled property name may
 *              lead to accidental mutation of the built-in Object prototype,
 *              and possibly escalate to remote code execution or cross-site scripting.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 6.1
 * @precision high
 * @id js/prototype-polluting-assignment
 * @tags security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-079
 *       external/cwe/cwe-094
 *       external/cwe/cwe-400
 *       external/cwe/cwe-471
 *       external/cwe/cwe-915
 */

import javascript
import semmle.javascript.security.dataflow.PrototypePollutingAssignmentQuery
import PrototypePollutingAssignmentFlow::PathGraph

from
  PrototypePollutingAssignmentFlow::PathNode source, PrototypePollutingAssignmentFlow::PathNode sink
where
  PrototypePollutingAssignmentFlow::flowPath(source, sink) and
  not isIgnoredLibraryFlow(source.getNode(), sink.getNode())
select
  sink.getNode(),
  source,
  sink,
  "This assignment may alter Object.prototype if a malicious '__proto__' string is injected from $@ (source at " +
    source.getNode().getFile().getRelativePath() + ":" +
    source.getNode().getLocation().getStartLine().toString() + ")." + "with describing : " + source.getNode().(Source).describe(),
  
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
// "col0","source","sink","col3","col4","col5","col6","col7","col8","col9"
// "items","req.params.id","items","This assignment may alter Object.prototype if a malicious '__proto__' string is injected from $@ (source at PrototypePollution.js:5).with describing : user controlled input","PrototypePollution.js",10,10,"PrototypePollution.js",5,5

// If encountering permssion issue, please run "chmod 644 {path_to_csv_file}"

// Why include isIgnoredLibraryFlow(source.getNode(), sink.getNode()) ?
// Because in prototype pollution, the vulnerability happens when inputting "__proto__" into the vulnerable code, but in some cases, the flow may come from some library code and the source is not really user-controlled, so we can ignore those flows to reduce false positives and make the results more concise and easier to understand.
// So we need to filter flows that start with library inputs and end with a write to a fixed property, which is the common pattern of those non-vulnerable flows.
// Here is the function:

// predicate isIgnoredLibraryFlow(ExternalInputSource source, Sink sink) {
//   exists(source) and                                              (which basically means the flow starts with an external input. Ex: req.params.id, req.body.name, etc)
//   exists(DataFlow::PropWrite write | sink = write.getBase() |      
//     // fixed property name
//     exists(write.getPropertyName())                               (which means the flow ends with a write to a fixed property, which is not vulnerable. Ex: obj["foo"], obj.bar, etc) 
//     or
//     // non-string property name (likely number)
//     exists(Expr prop | prop = write.getPropertyNameExpr() |       (which means the flow ends with a write to a non-string property, which is not vulnerable. Ex: obj[0], obj[1], etc)
//       not prop.analyze().getAType() = TTString()
//     )
//   )
// }
