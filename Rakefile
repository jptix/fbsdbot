require "rubygems"
require "rake/clean"
require "spec/rake/spectask"

$stdout.sync = true

desc "Run the specs under spec/"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = %w[--colour]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :compile_parser do
  
  desc 'Compile the Ruby parser to lib/irc/parser.rb'
  task :ruby do
    chdir "#{File.dirname(__FILE__)}/lib/irc" 
    print "Compiling..."
    sh "ragel -R rb_parser.rl -o parser.rb"
    puts "done!"
  end
  
  desc 'Compile the C parser to lib/irc/ext/parser.{bundle,so}'
  task :c do
    chdir "#{File.dirname(__FILE__)}/lib/irc/ext" 
    sh "ruby extconf.rb"
    sh "make clean"
    
    print "Compiling parser..."
    sh "ragel -C c_parser.rl -o parser.c"
    puts "done!"
    
    sh "make"
  end
end

desc 'Compile both parsers (Ruby and C extension)'
task :compile_parser => %w[compile_parser:ruby compile_parser:c]

CLEAN.include("lib/irc/ext/parser.bundle", "lib/irc/ext/parser.o",
              "lib/irc/ext/Makefile")

task :default => :spec