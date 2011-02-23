require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FeatureRich do

  it "should require activerecord" do
    lambda{ActiveRecord::Base}.should_not raise_exception
  end

  it "should declare FeatureRich::Config" do
    lambda{FeatureRich::Config}.should_not raise_exception
  end

  it "should respond_to #configure" do
    should respond_to(:configure).with(1)
  end
  
  it "shoud respond to #config" do
    should respond_to(:config)
    FeatureRich.config.should be_an_instance_of(FeatureRich::Config)
  end

  it "should return a FeatureRich::Config instance when invoking #configure" do
    FeatureRich.configure{}.should be_an_instance_of FeatureRich::Config
  end

  it "should invoke #instance_exec on FeatureRich::Config when invoking #configure" do
    lambda do
      @config = FeatureRich::Config.new
      @config.should_receive(:instance_exec).once
      @config.stub!(:feature_model).and_return("Feature")
      @config.stub!(:feature_model).and_return("Feature")
      FeatureRich.configure(@config) do
        feature_model = "Feature"
      end
    end.should_not raise_exception
  end

  it "should respond_to #run" do
    should respond_to(:run)
    FeatureRich.should_receive(:bootstrap!).once
    FeatureRich.config.should_receive(:merge!).once
    FeatureRich.run do
      feature_model "OtherModel"
    end
    FeatureRich.config.feature_model.should == "OtherModel"
  end

end
