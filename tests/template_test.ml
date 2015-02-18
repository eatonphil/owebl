open Template

let h_ctx = StringMap.empty;;
let h_ctx = StringMap.add "world" (Fulfillment.Variable "World") h_ctx;;
let h_ctx = StringMap.add "name" (Fulfillment.Variable "Phil") h_ctx;;
print_string ((templatize "Hello, `world`! My name is `name`." h_ctx) ^ "\n")
