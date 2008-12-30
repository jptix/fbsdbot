require "#{File.dirname(__FILE__)}/spec_helper"

describe "FBSDBot::IRC::Parser" do
  include SpecHelpers
  
  it "should parse a private message from user to user" do
    result = parse_message(":freenode-connect!freenode@freenode/bot/connect PRIVMSG utf82bot :hello\r\n")
    val    = result #.value
    val[:nick].should == "freenode-connect"
    val[:user].should == "freenode"
    val[:host].should == "freenode/bot/connect"
    val[:command].should == "PRIVMSG"
    val[:params].first.should == 'utf82bot'
    val[:params].last.should == 'hello'

  end
  
  it "should parse a channel message" do
    val = parse_message(":freenode-connect!freenode@freenode/bot/connect PRIVMSG #freebsd.no :hello\r\n")
    val[:params].first.should == '#freebsd.no'
    val[:params].last.should == 'hello'
  end
  
  it "should parse notices" do
    val = parse_message("NOTICE AUTH :*** Looking up your hostname...\r\n")
    val[:command].should == 'NOTICE'
  end
  
  it "should parse a host name prefix" do
    val = parse_message(":foo.freenode.net 372 utf82bot :- take place where the channel owner(s) has requested this\r\n")
    val[:command].should == '372'
    val[:server].should == 'foo.freenode.net'
  end
  
  it "should parse private messages where sender ident is missing" do
    val = parse_message(":Mr_Bond!~db@marvin.home.ip6.danielbond.org PRIVMSG #bot-test.no :!uptime\r\n")
    val[:nick].should == "Mr_Bond"
    val[:user].should == "~db"
  end
  
  it "should parse messages with UTF-8 chars" do
    val = parse_message(":jptix!markus@81.167.229.37 PRIVMSG #bot-test.no :æ ø å\r\n")
  end
  
  it "should parse a PING request" do
    val = parse_message("PING :irc.homelien.no\r\n")
    val[:command].should == 'PING'
    val[:params].should == %w[irc.homelien.no]
  end
  
  it "should should parse messages with colons" do
    val = parse_message(":jptix!markus@81.167.229.37 PRIVMSG #bot-test.no : :)\r\n")
  end
  
  it "should should return the correct target type for the specified target" do
    IRC::Parser.target_type("#foobar").should == :channel
    IRC::Parser.target_type("+foobar").should == :channel
    IRC::Parser.target_type("&foobar").should == :channel
    IRC::Parser.target_type("[foobar]").should == :user
    IRC::Parser.target_type("foo_bar").should == :user
  end
  
end
