open Server
open Utils

let () =
	let web_server = new server ~addr:"0.0.0.0" ~port:8000 in
	web_server#register_handler "/" Index.handler ["GET"];
	web_server#register_handler "/about" About.handler  ["GET"];
	web_server#start