require "rubygems"
require "rake/clean"
require "spec/rake/spectask"

$stdout.sync = true

desc "Run the specs under spec/"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = %w[--colour]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Compile the Ragel parser'

namespace :compile_parser do
  task :ruby do
    chdir "#{File.dirname(__FILE__)}/lib/irc" 
    print "Compiling..."
    sh "ragel -R rb_parser.rl -o parser.rb"
    puts "done!"
  end
  
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

CLEAN.include("lib/irc/ext/parser.bundle", "lib/irc/ext/parser.o",
              "lib/irc/ext/Makefile")

task :default => :spec