class MessageNode < Treetop::Runtime::SyntaxNode

  def value
    { 
      :command => command.text_value,
      :params  => params.value,
      :prefix  => (pre.prefix.value if pre.respond_to?(:prefix))
    }
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

class ParamsNode < Treetop::Runtime::SyntaxNode
  def value
    {
      :message => (msg.respond_to?(:trailing) ? msg.trailing : msg.middle).text_value,
      :to      => (receiver.target.to.text_value unless receiver.text_value.empty?)
    }
  end
end
