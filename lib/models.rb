require 'digest/sha1'
class User < ActiveRecord::Base
	attr_protected :passwd
	has_many :hosts
	
	def passwd=(password)
		write_attribute("passwd", Digest::SHA1.hexdigest(password))
	end
end

class Host < User
	set_table_name :hosts
end
