class MessageNode < Treetop::Runtime::SyntaxNode

  def value
    { 
      :command => command.text_value,
      :params  => (params.value if respond_to?(:params)),
      :prefix  => prefix_value
    }
  end
  
  private
  
  def prefix_value
    return unless pre.respond_to?(:prefix)
    pf = pre.prefix
    if pf.respond_to?(:nickname)
      res = {:nick => pf.nickname.text_value}
      if elem = pf.elements[1]
        res[:host] = elem.host.text_value if elem.respond_to?(:host)
        if elem.elements[0].respond_to?(:user)
          res[:user] = elem.elements[0].user.text_value
        end
      end
      
      res
    else
      {:host => pf.text_value}
    end
  end
end

class PrefixNode < Treetop::Runtime::SyntaxNode

  def value
    {
      :nick => nick.text_value,
      :user => elements[1].user.text_value,
      :host => elements[2].host.text_value,
    }
  end

end

module HostNode #< Treetop::Runtime::SyntaxNode
  def value
    {
      :host => text_value
    }
  end
end

class ParamsNode < Treetop::Runtime::SyntaxNode
  def value
    {
      :to => mdl.elements.first.middle.text_value,
      :message => trail.trailing.text_value,
    }
  rescue
    text_value.strip
  end
end
