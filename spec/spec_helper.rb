# encoding: utf-8
begin
  require "rubygems"
  gem "rspec"
rescue LoadError
end

require "spec"
require "stringio"
require "#{File.dirname(__FILE__)}/../lib/boot"

begin
  require "ruby-debug"
  Debugger.settings[:autoeval] = true
  Debugger.settings[:autolist] = 1
rescue LoadError
  puts "install ruby-debug if you want to use the debugger"
end

include FBSDBot

Log.level = :fatal

#
# helpers
#
module FBSDBot::SpecHelpers
  def mock_event_with_worker
    worker = mock('worker')
    event = mock('event')
    event.stub!(:worker).and_return(worker)
    return event, worker
  end

  def parse_message(string)
    res = IRC::Parser.parse_message(string)
    res.should_not be_empty
    res
  end

  # helper to capture $stdout/$stderr output in specs
  def capture(io, &block)
    last_level = Log.level
    Log.level = :debug

    out = StringIO.new
    old, reset = nil

    case io
    when :stdout
      old = $stdout
      $stdout = out
      reset = proc { $stdout = old }
      retval = proc { out.string }
    when :stderr
      old = $stderr
      $stderr = out
      reset = proc { $stderr = old }
      retval = proc { out.string }
    when :both
      old = [$stdout, $stderr]
      $stdout = out
      $stderr = out2 = StringIO.new
      reset = proc { $stdout, $stderr = old }
      retval = proc { [out.string, out2.string]}
    else
      raise "bad argument #{io.inspect}"
    end

    begin
      yield
    ensure
      reset.call
      Log.level = last_level
    end

    retval.call
  end
end
