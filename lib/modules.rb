
def seconds_to_s(seconds)
   s = seconds % 60
   m = (seconds /= 60) % 60
   h = (seconds /= 60) % 24
   d = (seconds /= 24)
   out = []
   out << "#{d}d" if d > 0
   out << "#{h}h" if h > 0
   out << "#{m}m" if m > 0
   out << "#{s}s" if s > 0
   out.length > 0 ? out.join(' ') : '0s'
end

def e_sh(str)
	str.to_s.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/, '\\').gsub(/\n/, "'\n'").sub(/^$/, "''")
end
