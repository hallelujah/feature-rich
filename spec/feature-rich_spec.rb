require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FeatureRich do

  it "should require activerecord" do
    lambda{ActiveRecord::Base}.should_not raise_exception
  end

  it "should declare FeatureRich::Config" do
    lambda{FeatureRich::Config}.should_not raise_exception
  end

  it "should respond to #configure" do
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
      FeatureRich.config.should_receive(:merge!).once
      FeatureRich.configure(@config) do
        feature_model = "Feature"
      end
    end.should_not raise_exception
  end

  it "should respond to #run" do
    should respond_to(:run)
    FeatureRich.should_receive(:bootstrap!).once
    FeatureRich.run do
      configure do
        feature_model "OtherModel"
        config_file  File.expand_path('../config.yml',__FILE__)
      end
    end
  end

  it "should define VALID_KEYS constant" do
    FeatureRich.const_defined?(:VALID_KEYS).should be_true
    FeatureRich::VALID_KEYS.should =~ [:feature_table, :feature_model, :config_file]
  end

  it "should raise ArgumentError on bad options " do
    lambda do
      FeatureRich.run do
        configure do
          bad_option "Hello"
        end
      end
    end.should raise_exception(ArgumentError)
  end

  it "should respond to #features" do
    FeatureRich.should respond_to(:features)
    FeatureRich.features.should == Set.new
  end

  it "should respond to #groups" do
    FeatureRich.should respond_to(:groups)
    FeatureRich.groups.should == HashWithIndifferentAccess.new
  end

  it "should respond to #feature" do
    FeatureRich.should respond_to(:feature).with(1)
    FeatureRich.feature(:fly)
    FeatureRich.features.should include(:fly)
  end

  it "should respond to #group" do
    FeatureRich.should respond_to(:feature).with(1)
    group_feature = mock('FeatureRich::GroupFeature')
    FeatureRich.groups.should_receive(:[]=).once.with(:masked,anything)
    FeatureRich.groups.should_receive(:[]).once
    FeatureRich.should_receive(:features=).once
    FeatureRich.should_receive(:features).once.and_return(Set.new)
    FeatureRich.group(:masked) do
      feature :black_color
      feature :full_face
    end
  end

end
