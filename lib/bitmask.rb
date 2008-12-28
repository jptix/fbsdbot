module FBSDBot

  # mix this in to a class that has a FLAGS hash of key => integer and
  # a @mask instance variable
  module BitMask

    def set_flag(key)
      @mask |= flag_for_key(key)
    end
    
    def unset_flag(sym)
      @mask &= flag_for_key(key)
    end
    
    private
    
    def has_flag?(sym)
      @mask & flag == flag
    end
    
    def flag_for_symbol(key)
      flag = FLAGS[key]
      raise "bad flag #{key.inspect}" unless flag
      
      flag
    end
  end
end