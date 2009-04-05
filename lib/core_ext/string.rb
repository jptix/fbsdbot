# encoding: utf-8
class String

  
  # todo, implement for IPv6 ips too
  def inet_aton ip
    split(/\./).map{|c| c.to_i}.pack("C*").unpack("N").first
  end

  #
  # Convert from camel case to snake case
  #
  #   'FooBar'.snake_case # => "foo_bar"
  #

  def snake_case
    gsub(/\B[A-Z][^A-Z]/, '_\&').downcase.gsub(' ', '_')
  end
  
  #
  # Convert from snake case to camel case
  #
  #   'foo_bar'.camel_case # => "FooBar"
  #

  def camel_case
   split('_').map{|e| e.capitalize}.join
  end
  
  
  #
  # A convenient way to do File.join
  #
  #   'a' / 'b' # => 'a/b'
  #

  def / obj
    File.join(self, obj.to_s)
  end

  #
  # Return the Integer ordinal of a one-character string.
  #
  # "a".ord         #=> 97
  #
  def ord
    self[0]
  end unless ''.respond_to?(:ord)

end
