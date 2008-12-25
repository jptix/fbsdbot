require "#{File.dirname(__FILE__)}/spec_helper"

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
    val[:params][:message].should == 'hello'
  end
  
  it "should parse notices" do
    result = parse("NOTICE AUTH :*** Looking up your hostname...\r\n")
    val    = result.value
    val[:command].should == 'NOTICE'
  end
  
  it "should parse a host name prefix" do
    result = parse(":foo.freenode.net 372 utf82bot :- take place where the channel owner(s) has requested this\r\n")
    val = result.value
    val[:command].should == '372'
    val[:prefix][:host].should == 'foo.freenode.net'
  end
  
  it "should parse private messages where sender ident is missing" do
    result = parse(":Mr_Bond!~db@marvin.home.ip6.danielbond.org PRIVMSG #bot-test.no :!uptime\r\n")
    var = result.value
    var[:prefix][:nick].should == "Mr_Bond"
    var[:prefix][:user].should == "~db"
  end
  
  it "should parse messages with UTF-8 chars" do
    result = parse(":jptix!markus@81.167.229.37 PRIVMSG #bot-test.no :æ ø å\r\n")
  end
  
  it "should parse a PING request" do
    result = parse("PING :irc.homelien.no\r\n")
  end
  
  it "should should parse messages with colons" do
    result = parse(":jptix!markus@81.167.229.37 PRIVMSG #bot-test.no : :)\r\n")
  end
  
end


__END__
