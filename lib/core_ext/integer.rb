# encoding: utf-8
class Integer
  #
  # Convert IP from number to String form
  #
  def inet_ntoa
    [self].pack("N").unpack("C*").join "."
  end
end
