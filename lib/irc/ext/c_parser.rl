// IRC Ragel parser - compile with `ragel -C c_parser.rl -o parser.c`

#include <ruby.h>

%%{
	machine irc;
	
	action strbegin { buf = p; }
    action stradd {}
    action command_finish { hash_insert(result, "command", rb_str_new(buf, p - buf)); }
	action servername_finish { hash_insert(result, "server", rb_str_new(buf, p - buf)); }
    action nickname_finish { hash_insert(result, "nick", rb_str_new(buf, p - buf)); }
    action user_finish { hash_insert(result, "user", rb_str_new(buf, p - buf)); }
    action host_finish { hash_insert(result, "host", rb_str_new(buf, p - buf)); }
	action params_begin { params = rb_ary_new(); }
	action param_begin { buf = p; }
    action param_add { }
	action param_finish { rb_ary_push(params, rb_str_new(buf, p - buf)); }
	action params_finish { hash_insert(result, "params", params); }
    action msgto_begin { result = Qnil; }
    action msgto_channel_finish { result = ID2SYM(rb_intern("channel")); }
    action msgto_mask_finish { result = ID2SYM(rb_intern("targetmask")); }
    action msgto_user_finish { result = ID2SYM(rb_intern("user")); }
    
	include "../rfc2812.rl";
    
}%%


void hash_insert(VALUE hash, char* key, VALUE val)
{
	VALUE key_sym = ID2SYM(rb_intern(key));
	rb_hash_aset(hash, key_sym, val);
}


%% write data;


VALUE parse_message(VALUE self, VALUE data)
{
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
	int cs = 0;
	char *p = RSTRING_PTR(data);
	char *pe = p + RSTRING_LEN(data);
	
	char *buf = 0;
	VALUE result, params = Qnil;
	
	%%write init;
	cs = irc_en_message_type;
	%%write exec;
	
	return result;
}


void Init_parser() {
	VALUE FBSDBot = rb_define_module("FBSDBot");
	VALUE IRC     = rb_define_module_under(FBSDBot, "IRC");
	VALUE Parser  = rb_define_module_under(IRC, "Parser");
	
	rb_define_module_function(Parser, "parse_message", parse_message, 1);
	rb_define_module_function(Parser, "target_type", target_type, 1);
}
