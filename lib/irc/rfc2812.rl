%%{
	machine irc;

	SPACE      = " ";
	crlf       = "\r" "\n";
	letter   = 0x41..0x5a | 0x61..0x7a;
	digit_   = 0x30..0x39;
	hexdigit = digit_ | "A"i | "B"i | "C"i | "D"i | "E"i | "F"i;
	special  = 0x5b..0x60 | 0x7b..0x7d;
	
	user       = ^[\0\r\n@! ]+;
	key        = ( 0x01..0x05 | 0x07..0x08 | "\f" | 0x0e..0x1f | 0x21..0x7f ){1,23};
	nowild     = extend - ( 0 | '*' | '?'); #  any octet except NUL, "*", "?"
	noesc      = extend - ( 0 | '\\'); # any octet except NUL and "\"
	wildone    = "?";
	wildmany   = "*";
	mask       = ( nowild | ( noesc wildone ) | ( noesc wildmany ) )*;
	matchone   = 0x01..0xff;
	matchmany  = matchone*;
	nospcrlfcl = extend - ( 0 | SPACE | '\r' | '\n' | ':' ); # ; any octet except NUL, CR, LF, " " and ":"
	middle     = nospcrlfcl ( ":" | nospcrlfcl )*;
	trailing   = ( ":" | " " | nospcrlfcl )*;
	
	nickname   = ( letter | special ) ( letter | digit_ | special | "-" ){,15};
	shortname  = ( letter | digit_ ) ( letter | digit_ | "-" )* ( letter | digit_ )*;
	hostname   = shortname ( [./] shortname )*;
	servername = hostname; # add cloak
	target     = nickname | servername;
	channelid  = ( 0x41..0x5a | digit_ ){5};
	chanstring = extend - (0 | 7 | '\r' | '\n' | SPACE | "," | ":" ); # any octet except NUL, BELL, CR, LF, " ", "," and ":"
	channel    = ( "#" | "+" | ( "!" channelid ) | "&" ) chanstring ( ":" chanstring )?;
	ip4addr    = digit_{1,3} "." digit_{1,3} "." digit_{1,3} "." digit_{1,3};
	ip6addr    = ( hexdigit+ ( ":" hexdigit+ ){7} ) | ( "0:0:0:0:0:" ( "0" | "FFFF"i ) ":" ip4addr );
	hostaddr   = ip4addr | ip6addr;
	host       = hostname | hostaddr;
	targetmask = ( "$" | "#" ) mask;
	msgto      = channel @msgto_channel_finish
                     | ( user ( "%" host )? "@" servername ) @msgto_user_finish | ( user "%" host ) @msgto_user_finish | targetmask | nickname @msgto_user_finish | ( nickname "!" user "@" host ) @msgto_user_finish ;
	msgtarget  = msgto ( "," msgto )*;
	
	prefix     = servername >strbegin $stradd %servername_finish | 
	             ( nickname >strbegin $stradd %nickname_finish ( ( "!" user >strbegin $stradd %user_finish )? "@" host >strbegin $stradd %host_finish)? );
	         
	command    = letter+ | digit_{3};
        params1    = ( ( SPACE middle >param_begin $param_add %param_finish){,14} ( SPACE ":" trailing >param_begin $param_add %param_finish)? );
        params2    = ( ( SPACE middle >param_begin $param_add %param_finish){14} ( SPACE ":"? trailing >param_begin $param_add %param_finish)? );
        params     = (params1 %params_finish | params2 %params_finish ) >params_begin;
	message    = ( ":" prefix SPACE )? command >strbegin $stradd %command_finish params? crlf;

        
	# instantiate machine rules
	main:= message;
    message_type := msgto;
}%%
