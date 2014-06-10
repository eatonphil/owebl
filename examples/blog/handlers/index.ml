let handler request_uri request_method =
	let template = Utils.read_file_to_string "templates/index.html" in template