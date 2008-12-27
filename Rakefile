require "rubygems"
require "spec/rake/spectask"

$stdout.sync = true

desc "Run the specs under spec/"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = %w[--colour]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Compile the Ragel parser'
task :compile_parser do
  chdir "#{File.dirname(__FILE__)}/lib/irc" 
  print "Compiling..."
  sh "ragel -R rfc2812 -o parser.rb"
  puts "done!"
end