require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FeatureRich::Engine do
  before do
    FeatureRich::Engine.config.clear
    FeatureRich::Engine.groups.clear
    FeatureRich::Engine.features.clear
  end

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
    FeatureRich::Engine.config.should be_an_instance_of(FeatureRich::Config)
  end

  it "should return a FeatureRich::Config instance when invoking #configure" do
    FeatureRich::Engine.configure{}.should be_an_instance_of FeatureRich::Config
  end

  it "should invoke #instance_exec on FeatureRich::Config when invoking #configure" do
    lambda do
      @config = FeatureRich::Config.new
      @config.should_receive(:instance_exec).once
      @config.stub!(:feature_model).and_return("Feature")
      FeatureRich::Engine.config.should_receive(:merge!).once
      FeatureRich::Engine.configure(@config) do
        feature_model = "Feature"
      end
    end.should_not raise_exception
  end

  it "should respond to #run" do
    should respond_to(:run)
    FeatureRich::Engine.should_receive(:bootstrap!).once
    FeatureRich::Engine.run do
      configure do
        feature_model "OtherModel"
        config_file  File.expand_path('../config.yml',__FILE__)
      end
    end
  end

  it "should define VALID_KEYS constant" do
    FeatureRich::Engine.const_defined?(:VALID_KEYS).should be_true
    FeatureRich::Engine::VALID_KEYS.should =~ [:feature_table, :feature_model, :config_file]
  end

  it "should raise ArgumentError on bad options " do
    lambda do
      FeatureRich::Engine.run do
        configure do
          bad_option "Hello"
        end
      end
    end.should raise_exception(ArgumentError)
  end

  it "should respond to #features" do
    FeatureRich::Engine.should respond_to(:features)
    FeatureRich::Engine.features.should == Set.new
  end

  it "should respond to #groups" do
    FeatureRich::Engine.should respond_to(:groups)
    FeatureRich::Engine.groups.should == HashWithIndifferentAccess.new
  end

  it "should respond to #feature" do
    FeatureRich::Engine.should respond_to(:feature).with(1)
    FeatureRich::Engine.feature(:fly)
    FeatureRich::Engine.features.should include(:fly)
    FeatureRich::Engine.groups.should include(:_none_)
    FeatureRich::Engine.groups[:_none_].sets.should =~ [:fly]
  end

  it "should respond to #group" do
    FeatureRich::Engine.should respond_to(:feature).with(1)
    group_feature = mock('FeatureRich::GroupFeature')
    FeatureRich::Engine.groups.should_receive(:[]=).once.with(:masked,anything)
    FeatureRich::Engine.groups.should_receive(:[]).once
    FeatureRich::Engine.should_receive(:features=).once
    FeatureRich::Engine.should_receive(:features).once.and_return(Set.new)
    FeatureRich::Engine.group(:masked) do
      feature :black_color
      feature :full_face
    end
  end

  it "should respond to load!" do
    FeatureRich::Engine.should respond_to(:load!)
    Rails = mock('hello')
    root = mock('root')
    root.stub!(:join).and_return(File.expand_path('../config.rb',__FILE__))
    Rails.stub!(:root).and_return(root)
    FeatureRich::Engine.load!
    FeatureRich::Engine.groups.should have_key(:color)
    FeatureRich::Engine.features.to_a.should =~ [ :red,:blue ]
  end

end
