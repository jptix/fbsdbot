# encoding: utf-8
module FBSDBot
  module Boolean
    def tiny_s
      self.is_a?(TrueClass) ? "Y" : "N"
    end
  end
end

class TrueClass; include FBSDBot::Boolean; end
class FalseClass; include FBSDBot::Boolean; end
