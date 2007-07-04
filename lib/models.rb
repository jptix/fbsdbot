class User < ActiveRecord::Base
	has_many :hosts
end

class Host < User
	set_table_name :hosts
end
