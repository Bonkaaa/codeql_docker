import tree_sitter_javascript as tsjavascript
from tree_sitter import Language, Parser

# 1. Load the JavaScript language
JS_LANGUAGE = Language(tsjavascript.language())

# 2. Initialize the parser
parser = Parser(JS_LANGUAGE)

# 3. Define your source code
example_code = """
function greet(name) {
    console.log("Hello, " + name);
}
"""

# 4. Parse the code
tree = parser.parse(bytes(example_code, "utf8"))

# 5. Access the root node
root_node = tree.root_node
print(f"Root type: {root_node.type}")
print(f"Children count: {root_node.child_count}")

