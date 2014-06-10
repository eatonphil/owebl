let file = "examples/blog/templates/about.html"

let handler request_uri request_method =
	let template = Utils.read_file_to_string file in template