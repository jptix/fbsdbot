require "#{File.dirname(__FILE__)}/spec_helper"

describe "EventProducer" do
  before(:each) do
    @conn = mock("EMCore")
    @ep = IRC::EventProducer.new(@conn)
  end

  it "should create the correct event when receiving a private message" do
    event = @ep.parse_line ":jptix!markus@nextgentel.com PRIVMSG #bot-test.no :æ ø å\r\n"
    event.should be_instance_of(PrivateMessageEvent)
    event.type.should == :private_message
    event.message.should == "æ ø å"
    event.should be_channel
    
    event.should respond_to(:reply)
    @conn.should_receive(:send_privmsg).with("hello","#bot-test.no")
    event.reply("hello")
  end
  
  it "should create the correct event when receiving a ping" do
    @conn.should_receive(:send_pong).with("irc.homelien.no")
    event = @ep.parse_line "PING :irc.homelien.no\r\n"
    event.should be_instance_of(PingEvent)
    event.type.should == :ping
  end
  
  it "should create the correct event for a ctcp action" do
    event = @ep.parse_line ":jptix!markus@nextgentel.com PRIVMSG #bot-test.no :\001ACTION foo\001\r\n"
    event.should be_instance_of(CTCPActionEvent)
    event.to.should == "#bot-test.no"
    event.message.should == "foo"
  end
  
  it "should create the correct event for ctcp version" do
    event = @ep.parse_line ":jptix!markus@nextgentel.com PRIVMSG testbot20 :\001VERSION\001\r\n"
    
    event.should be_instance_of(CTCPVersionEvent)
    
    event.user.nick.should == 'jptix'
    event.user.user.should == 'markus'
    event.user.host.should == 'nextgentel.com'
    
    event.should respond_to(:reply)
    @conn.should_receive(:send_notice).with("\001VERSION hello\001", "jptix")
    event.reply "hello"
  end
  
  it "should create the correct event for motd lines" do
    event = @ep.parse_line ":irc.homelien.no 372 testbot20 :- This is \002irc.homelien.no\002 on \002EFnet\002, the world's oldest living\r\n"
    event.should be_instance_of(MotdEvent)
    event.to.should == "testbot20"
    event.server.should == "irc.homelien.no"
    event.message.should == "- This is \002irc.homelien.no\002 on \002EFnet\002, the world's oldest living"
  end
  
  it "should create the correct event for a notice" do
    event = @ep.parse_line ":jptix!markus@nextgentel.com NOTICE testbot20 :foo\r\n"
    
    event.should be_instance_of(NoticeEvent)
    event.should be_kind_of(Replyable)
    
    event.user.nick.should == 'jptix'
    event.user.user.should == 'markus'
    event.user.host.should == 'nextgentel.com'
    
    event.to.should == 'testbot20'
    event.message.should == 'foo'
  end
  
  it "should create the correct event when receiving end-of-motd" do
    event = @ep.parse_line ":irc.homelien.no 376 testbot20 :End of /MOTD command.\r\n"
    event.should be_instance_of(EndOfMotdEvent)
    event.server.should == "irc.homelien.no"
  end
  
  it "should create the correct event when someone joins a channel" do
    event = @ep.parse_line ":testbot20!~FBSDBot@nextgentel.com JOIN :#bot-test.no\r\n"
    event.should be_instance_of(JoinEvent)
    event.nick.should == "testbot20"
    event.channel.should == "#bot-test.no"
    event.host.should == 'nextgentel.com'
    event.user.should == '~FBSDBot'
  end
  
  it "should create the correct event when receiving the names list after joining a channel" do
    event = @ep.parse_line ":irc.homelien.no 353 testbot20 @ #bot-test.no :testbot20 @jptix @Mr_Bond\r\n"
    event.should be_instance_of(NamesEvent)
    event.names.should == ["testbot20", "@jptix", "@Mr_Bond"]
  end
  
  it "should create the correct event when receving 'end of names list'" do
    event = @ep.parse_line ":irc.homelien.no 366 testbot20 #bot-test.no :End of /NAMES list.\r\n"
    event.should be_instance_of(EndOfNamesEvent)
    event.channel.should == "#bot-test.no"
    event.server.should == "irc.homelien.no"
  end
    
  it "should create the correct event when someone quits" do
    event = @ep.parse_line ":tesvbot20!~FBSDBot@nextgentel.com QUIT :Remote host closed the connection\r\n"
    event.should be_instance_of(QuitEvent)
    event.user.nick.should == "tesvbot20"
    event.user.user.should == "~FBSDBot"
    event.user.host.should == "nextgentel.com"
    event.message.should == "Remote host closed the connection"
  end
  
  it "should create the correct event when someone joins a channel" do
    event = @ep.parse_line ":jptix!markus@nextgentel.com PART #bot-test.no :bye\r\n"
    event.should be_instance_of(PartEvent)
    event.user.nick.should == "jptix"
    event.user.host.should == "nextgentel.com"
    event.user.user.should == "markus"
    event.channel.should == "#bot-test.no"
    event.message.should == "bye"
  end
  
end

