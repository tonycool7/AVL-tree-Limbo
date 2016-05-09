implement client;
include "sys.m";
sys: Sys;
Connection: import Sys;
include "draw.m";
FD : import sys;
stdin, stdout : ref Sys->FD;	

client: module {
	init: fn(nil: ref Draw->Context, argv: list of string);
};

init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;

	sys->print("Client started...\n");
	stdin = sys->fildes(0);
	stdout = sys->fildes(1);
	(n,conn) := sys->dial("tcp!127.0.0.1!6666",nil);

	if(n < 0){
		sys->print("Connection error!");
		exit;
	}else{
		sys->print("Connection successful\n");
	}
	buf := array [sys->ATOMICIO] of byte;
	wdfd := sys->open(conn.dir+"/data",Sys->OWRITE);
	rdfd := sys->open(conn.dir+"/data",Sys->OREAD);
	rfd := sys->open(conn.dir+"/remote",Sys->OREAD);
	reply : string;

	while(1){
		sys->print("Enter request to send to server: ");
		sys->read(stdin, buf, len buf);
		sys->write(wdfd, buf, len buf);
		msg := sys->read(rdfd, buf, len buf);
		reply = string buf[:msg];
		sys->print("Server's reply, word definition: %s\n", reply);
		sys->print("\n");
	}
	
	
}