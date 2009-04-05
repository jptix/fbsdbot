# encoding: utf-8
module FBSDBot

  # mix this in to a class that has a FLAGS hash of key => integer and
  # a @mask instance variable
  module BitMask

    def set_flag(key)
      @bitmask |= flag_for_key(key)
    end
    
    def unset_flag(key)
      @bitmask ^= flag_for_key(key)
    end
    
    def has_flag?(key)
      flag = flag_for_key(key)
      @bitmask & flag == flag
    end
    
    private
    
    def flag_for_key(key)
      flag = self.class::FLAGS[key]
      raise "bad flag #{key.inspect}" unless flag
      
      flag
    end
  end
end
