# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"

describe "YAMLUserStore" do
  
  before(:each) do
    @file = 'test-fbsdbot-userstore.yml'
    @ds = YAMLUserStore.new(@file)
  end
  
  after(:each) do
    FileUtils.rm(@file)
  end
  
  describe "#save" do
    it "should save the given user" do
      @ds.save(User.new(:nick => 'foo', :user => 'bar', :host => "baz"))
    end
    
    it "should raise a TypeError if the object is not a User" do
      lambda { @ds.save('foo') }.should raise_error(TypeError)
    end
  end
  
  describe "#fetch" do
    it "should fetch previously saved users by regexp" do
      u = User.new(:nick => 'foo', :user => 'bar', :host => "baz")
      @ds.save(u)
      @ds.fetch(:regexp => /foo!(\w+)@baz/).should == u
    end

    it "should fetch previously saved user by object" do
      u = User.new(:nick => 'foo', :user => 'bar', :host => "baz")
      @ds.save(u)
      @ds.fetch(:user => u).should == u
    end
    
    it "should fetch previously saved user by hostmask" do
      u = User.new(:nick => 'foo', :user => 'bar', :host => "baz")
      @ds.save(u)
      @ds.fetch(:hostmask => "foo!bar@baz")
    end

    it "should fetch previously saved user by hostmask when the given hostmask matches the user's regexp" do
      u = User.new(:hostmask_exp => /foo!bar/)
      @ds.save(u)
      @ds.fetch(:hostmask => "foo!bar@baz")
    end
  end
  
  describe "#remove" do
    it "should remove the user from the data store" do
      u = User.new(:nick => 'foo', :user => 'bar', :host => "baz")
      @ds.save(u)
      @ds.remove(:user => u)
      @ds.fetch_all.size.should == 0
    end
    
    it "should return nil if the user doesn't exist" do
      @ds.remove(:hostmask => "foobar").should be_nil
    end
  end
  
  describe "#fetch_all" do
    it "should fetch all users" do
      u = User.new(:nick => 'foo', :user => 'bar', :host => "baz")
      @ds.save(u)
      
      all = @ds.fetch_all
      all.should be_kind_of(Array)
      all.size.should == 1
    end
  end
end
