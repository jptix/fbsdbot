class Users < ActiveRecord::Base
	has_many :hosts
end

class Hosts < Users

end
