# ruby parser - compile with `ragel -R rb_parser.rl -o parser.rb`

%%{
	machine irc;
	
    action strbegin { buf = "" }
    action stradd { buf << fc }
    action command_finish { result[:command] = buf }
    action servername_finish { result[:server] = buf }
    action nickname_finish { result[:nick] = buf }
    action user_finish { result[:user] = buf }
    action host_finish { result[:host] = buf }
    action params_begin { params = [] }
    action param_begin { params << "" }
    action param_add { params.last << fc }
    action param_finish {}
    action params_finish { result[:params] = params }
    action msgto_channel_finish { result = :channel }
    action msgto_user_finish { result = :user }
    action msgto_begin { result = nil }
    action msgto_mask_finish { result = :targetmask }

	include "rfc2812.rl";
}%%

module FBSDBot
  module IRC
    module Parser
    
      %% write data;

      module_function

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
        
    end # Parser
  end # IRC
end # FBSDBot


if __FILE__ == $0
   FBSDBot::IRC::Parser.parse_message(STDIN.read)
end
