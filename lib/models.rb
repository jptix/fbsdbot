require 'digest/sha1'
class User < ActiveRecord::Base
	attr_protected :passwd
	has_many :hosts
	
	def check_password(passwd)
		return true if (self.passwd == Digest::SHA1.hexdigest(passwd))
		false 
	end
end

class Host < User
	set_table_name :hosts
end
