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
    it "should fetch previously saved users" do
      u = User.new("foo", "bar", "baz")
      @ds.save(u)
      
      @ds.fetch(u.string).should == u
    end
  end
  
  describe "#fetch_all" do
    it "should fetch all users" do
      u = User.new("foo", "bar", "baz")
      @ds.save(u)
      
      all = @ds.fetch_all
      all.should be_instance_of(Array)
      all.size.should == 1
    end
  end
  
  describe "#fetch_identified" do
    it "should fetch all identified users" do
      identified_user = User.new("foo", "bar", "baz")
      identified_user.set_flag(:identified)
      @ds.save(identified_user)
      
      normal_user = User.new("a", "b", "c")
      @ds.save(normal_user)
      
      users = @ds.fetch_identified
      users.size.should == 1
      users.shift.should == identified_user
    end
  end
  
end