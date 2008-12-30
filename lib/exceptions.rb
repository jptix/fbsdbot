module FBSDBot
  module Exceptions
    class ConfigurationError < ArgumentError; end
    class HostmaskMismatchError < StandardError; end
  end
end