require "rubygems"
require "spec"
require "treetop"
require "ruby-debug"
require "#{File.dirname(__FILE__)}/../lib/irc/parser"


describe "Treetop IRCParser" do
  before(:all) do
    @parser = IRCParser.new
  end
  
  def parse(string)
    res = @parser.parse(string)
    unless res
      puts @parser.terminal_failures
      p @parser.failure_reason
      debugger if $stdout.tty?
    end
    res.should_not be_nil
    res
  end
  
  it "should parse a private message from user to user" do
    result = parse(":freenode-connect!freenode@freenode/bot/connect PRIVMSG utf82bot :hello\r\n")
    val    = result.value
    val[:prefix][:nick].should == "freenode-connect"
    val[:prefix][:user].should == "freenode"
    val[:prefix][:host].should == "freenode/bot/connect"
    val[:command].should == "PRIVMSG"
    val[:params][:to].should == 'utf82bot'
    val[:params][:message].should == 'hello'
  end
  
  it "should parse a channel message" do
    result = parse(":freenode-connect!freenode@freenode/bot/connect PRIVMSG #freebsd.no :hello\r\n")
    val    = result.value
    val[:params][:to].should == '#freebsd.no'
  end
  
  it "should parse notices" do
    result = parse("NOTICE AUTH :*** Looking up your hostname...\r\n")
    val    = result.value
    val[:command].should == 'NOTICE'
  end
  
  it "should parse a host address prefix" do
    result = parse(":10.0.0.2 372 utf82bot :- take place where the channel owner(s) has requested this\r\n")
    result.value[:command].should == '372'
    result.value[:prefix][:host].should == '10.0.0.2'
  end

  it "should parse a host name prefix" do
    result = parse(":foo.freenode.net 372 utf82bot :- take place where the channel owner(s) has requested this\r\n")
    result.value[:command].should == '372'
    result.value[:prefix][:host].should == 'foo.freenode.net'
  end
end


__END__

:freenode-connect!freenode@freenode/bot/connect PRIVMSG utf82bot :hello
:10.0.0.2 372 utf82bot :- take place where the channel owner(s) has requested this