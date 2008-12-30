// IRC Ragel parser - compile with `ragel -C c_parser.rl -o parser.c`

#include <ruby.h>

#define hash_set_string(key, ptr, len)\
	rb_hash_aset(result, ID2SYM(rb_intern(key)), rb_str_new(ptr, len));
#define hash_set_value(key, val)\
	rb_hash_aset(result, ID2SYM(rb_intern(key)), val);

%%{
	machine irc;

	action strbegin			 	{ buf = p; 											}
	action stradd				{													}
	action command_finish	 	{ hash_set_string("command", buf, p - buf); 		}
	action servername_finish 	{ hash_set_string("server", buf, p - buf); 			}
	action nickname_finish 	 	{ hash_set_string("nick", buf, p - buf); 			}
	action user_finish 		 	{ hash_set_string("user", buf, p - buf); 			}
	action host_finish 		 	{ hash_set_string("host", buf, p - buf); 			}
	action params_begin 	 	{ params = rb_ary_new(); 							}
	action param_begin 		 	{ buf = p; 											}
	action param_add 		 	{ 													}
	action param_finish 	 	{ rb_ary_push(params, rb_str_new(buf, p - buf));	}
	action params_finish 	 	{ hash_set_value("params", params); 				}
	action msgto_begin 		 	{ result = Qnil; 									}
	action msgto_channel_finish { result = ID2SYM(rb_intern("channel")); 			}
	action msgto_mask_finish 	{ result = ID2SYM(rb_intern("targetmask")); 		}
	action msgto_user_finish 	{ result = ID2SYM(rb_intern("user")); 				}

	include "../rfc2812.rl";
}%%


void hash_insert(VALUE hash, char* key, VALUE val)
{
	rb_hash_aset(hash, ID2SYM(rb_intern(key)), val);
}


%% write data;


VALUE parse_message(VALUE self, VALUE data)
{
	Check_Type(data, T_STRING);

	int cs = 0;
	char *p = RSTRING_PTR(data);
	char *pe = p + RSTRING_LEN(data);

	VALUE result = rb_hash_new();
	VALUE params = Qnil;
	char *buf = 0;

	%%write init;
	%%write exec;

	return result;
}

VALUE target_type(VALUE self, VALUE data)
{
	Check_Type(data, T_STRING);

	int cs = 0;
	char *p = RSTRING_PTR(data);
	char *pe = p + RSTRING_LEN(data);

	char *buf = 0;
	VALUE result, params = Qnil;

	cs = irc_en_message_type;
	%%write exec;

	return result;
}


void Init_parser() 
{
	VALUE FBSDBot = rb_define_module("FBSDBot");
	VALUE IRC	  = rb_define_module_under(FBSDBot, "IRC");
	VALUE Parser  = rb_define_module_under(IRC, "Parser");

	rb_define_module_function(Parser, "parse_message", parse_message, 1);
	rb_define_module_function(Parser, "target_type", target_type, 1);
}
