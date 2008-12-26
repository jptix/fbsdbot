# IRC Ragel parser - compile with `ragel -R irc.rl -o parser.rb`

%%{
	machine irc;
        
        action strbegin {
                buf = ""
        }
        
        action stradd {
                buf << fc
        }
        
        action command_finish {
                result[:command] = buf
        }

        action servername_finish {
                result[:server] = buf
        }

        action nickname_finish {
                result[:nick] = buf
        }

        action user_finish {
                result[:user] = buf
        }

        action host_finish {
                result[:host] = buf
        }
        
        action params_begin {
                params = []
        }
        
        action param_begin {
                params << ""
        }
        
        action param_add {
                params.last << fc
        }
         
        action params_finish {
                result[:params] = params
        }
        
	SPACE      = " ";
	crlf       = "\r" "\n";
	letter   = 0x41..0x5a | 0x61..0x7a;
	digit_   = 0x30..0x39;
	hexdigit = digit_ | "A"i | "B"i | "C"i | "D"i | "E"i | "F"i;
	special  = 0x5b..0x60 | 0x7b..0x7d;
	
	user       = ^[\0\r\n@! ]+;
	key        = ( 0x01..0x05 | 0x07..0x08 | "\f" | 0x0e..0x1f | 0x21..0x7f ){1,23};
	nowild     = 0x01..0x29 | 0x2b..0x3e | 0x40..0xff;
	noesc      = 0x01..0x5b | 0x5d..0xff;
	wildone    = "?";
	wildmany   = "*";
	mask       = ( nowild | ( noesc wildone ) | ( noesc wildmany ) )*;
	matchone   = 0x01..0xff;
	matchmany  = matchone*;
	nospcrlfcl = ^[\0\r\n :];
	middle     = nospcrlfcl ( ":" | nospcrlfcl )*;
	trailing   = ( ":" | " " | nospcrlfcl )*;
	
	nickname   = ( letter | special ) ( letter | digit_ | special | "-" ){,15};
	shortname  = ( letter | digit_ ) ( letter | digit_ | "-" )* ( letter | digit_ )*;
	hostname   = shortname ( [./] shortname )*;
	servername = hostname; # add cloak
	target     = nickname | servername;
	channelid  = ( 0x41..0x5a | digit_ ){5};
	chanstring = 0x01..0x07 | 0x08..0x09 | 0x0b..0x0c | 0x0e..0x1f | 0x21..0x2b | 0x2d..0x39 | 0x3b..0xff;
	channel    = ( "#" | "+" | ( "!" channelid ) | "&" ) chanstring ( ":" chanstring )?;
	ip4addr    = digit_{1,3} "." digit_{1,3} "." digit_{1,3} "." digit_{1,3};
	ip6addr    = ( hexdigit+ ( ":" hexdigit+ ){7} ) | ( "0:0:0:0:0:" ( "0" | "FFFF"i ) ":" ip4addr );
	hostaddr   = ip4addr | ip6addr;
	host       = hostname | hostaddr;
	targetmask = ( "$" | "#" ) mask;
	msgto      = channel | ( user ( "%" host )? "@" servername ) | ( user "%" host ) | targetmask | nickname | ( nickname "!" user "@" host );
	msgtarget  = msgto ( "," msgto )*;
	
	prefix     = servername >strbegin $stradd %servername_finish | 
	             ( nickname >strbegin $stradd %nickname_finish ( ( "!" user >strbegin $stradd %user_finish )? "@" host >strbegin $stradd %host_finish)? );
	         
	command    = letter+ | digit_{3};
        params1    = ( ( SPACE middle >param_begin $param_add ){,14} ( SPACE ":" trailing >param_begin $param_add)? );
        params2    = ( ( SPACE middle >param_begin $param_add){14} ( SPACE ":"? trailing >param_begin $param_add)? );
        params     = (params1 %params_finish | params2 %params_finish ) >params_begin;
	message    = ( ":" prefix SPACE )? command >strbegin $stradd %command_finish params? crlf;

        
	# instantiate machine rules
	main:= message;
}%%

module FBSDBot
  module IRC
    module Parser
    
      %% write data;
    
      def self.parse(data)
        
        result = {}
        buf = ""
        
        %% write init;
        %% write exec;
        
        if $DEBUG
          Kernel.p :finished => cs, :consumed => p, :total => pe, :result => result
        end
        
        result
      end
      
      def self.parse_msg_target(data)
        %% write init;
        cs = 
      end
    end
  end
end


%% write data;


if __FILE__ == $0
   FBSDBot::IRC::Parser.parse(STDIN.read)
end

