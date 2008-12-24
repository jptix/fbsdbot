class MessageNode < Treetop::Runtime::SyntaxNode
  
  def value
    r = { :command => command.text_value,
         :params  => params.text_value }
    r[:prefix] = pre.prefix.value if pre.respond_to?(:prefix)
    r
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

class HostNode < Treetop::Runtime::SyntaxNode
  def value
    {
      :host => text_value
    }
  end
end
