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
      @ds.save(User.new("foo", "bar", "baz"))
    end
    
    it "should raise a TypeError if the object is not a User" do
      lambda { @ds.save('foo') }.should raise_error(TypeError)
    end
  end
  
  describe "#fetch" do
    it "should fetch previously saved users by regexp" do
      u = User.new("foo", "bar", "baz")
      @ds.save(u)
      @ds.fetch(:regexp => /foo!(\w+)@baz/).should == u
    end

    it "should fetch previously saved user by object" do
      u = User.new("foo", "bar", "baz")
      @ds.save(u)
      @ds.fetch(:user => u).should == u
    end
  end
  
  describe "#fetch_all" do
    it "should fetch all users" do
      u = User.new("foo", "bar", "baz")
      @ds.save(u)
      
      all = @ds.fetch_all
      all.should be_kind_of(Array)
      all.size.should == 1
    end
  end
end