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
        
        action msgto_channel_finish {
                result = :channel
        }
        
        action msgto_user_finish {
                result = :user
        }
        
        action msgto_begin {
                result = nil
        }

        action msgto_mask_finish {
                result = :targetmask
        }
        
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
        params1    = ( ( SPACE middle >param_begin $param_add ){,14} ( SPACE ":" trailing >param_begin $param_add)? );
        params2    = ( ( SPACE middle >param_begin $param_add){14} ( SPACE ":"? trailing >param_begin $param_add)? );
        params     = (params1 %params_finish | params2 %params_finish ) >params_begin;
	message    = ( ":" prefix SPACE )? command >strbegin $stradd %command_finish params? crlf;

        
	# instantiate machine rules
	main:= message;
        message_type := msgto;
}%%

module FBSDBot
  module IRC
    module Parser
    
      %% write data;
    
      class << self
        def parse_message(data)
        
          result = {}
          buf = ""
        
          %% write init;
          %% write exec;
        
          if $DEBUG
            Kernel.p :finished => cs, :consumed => p, :total => pe, :result => result
          end
        
          result
        end
        
        def target_type(data)
          result = nil
          
          %% write init;
          cs = irc_en_message_type;
          %% write exec;

          if $DEBUG
            Kernel.p :finished => cs, :consumed => p, :total => pe, :result => result
          end
          
          result
        end
        
      
      end # class << self
    end # Parser
  end # IRC
end # FBSDBot


%% write data;


if __FILE__ == $0
   FBSDBot::IRC::Parser.parse(STDIN.read)
end

