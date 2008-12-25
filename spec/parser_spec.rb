require "#{File.dirname(__FILE__)}/spec_helper"

describe "Parser" do
  before(:all) do
    @parser = FBSDBot::IRC::Parser.new
  end

  it "should return a :private_message Event for a private message" do
    event = @parser.parse_line ":jptix!markus@81.167.229.37 PRIVMSG #bot-test.no :æ ø å\r\n"
    event.type.should == :private_message
    event.message.should == "æ ø å"
  end
  
end