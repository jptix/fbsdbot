module FBSDBot
  class WhoisUserEvent < Event
    attr_reader :to, :real_name, :user, :server

    def initialize(conn, opts = {})
      super(conn)
      {:server=>"irc.homelien.no", :command=>"311", :params=>["testbot20", "Mr_Bond", "~db", "marvin.home.ip6.danielbond.org", "*", "DB5868-RIPE"]}
      @server = opts[:server]
      @to, nick, user, host, _, @real_name = opts[:params]
      @user = fetch_user(nick, user, host)
    end
    
  end
end