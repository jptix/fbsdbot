require "#{File.dirname(__FILE__)}/spec_helper"

describe "YAMLUserStore" do
  
  before(:each) do
    @file = 'fbsdbot-userstore.yml'
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
  
  describe "fetch" do
    it "should fetch previously saved users" do
      u = User.new("foo", "bar", "baz")
      @ds.save(u)
      @ds.fetch(u.string).should == u
    end
  end
  
end