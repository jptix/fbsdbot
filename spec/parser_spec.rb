require "#{File.dirname(__FILE__)}/spec_helper"

describe "EventProducer" do
  before(:all) do
    @conn = mock("Connection")
    @parser = FBSDBot::IRC::EventProducer.new(@conn)
  end

  it "should return a :private_message Event for a private message" do
    event = @parser.parse_line ":jptix!markus@81.167.229.37 PRIVMSG #bot-test.no :æ ø å\r\n"
    event.should be_instance_of(PrivateMessageEvent)
    event.type.should == :private_message
    event.message.should == "æ ø å"
  end
  
end