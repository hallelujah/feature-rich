require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/db_helper')

describe FeatureRich::ModelBehaviour do
  # Called once
  before(:all) do
    FeatureRich::Engine.run do
      configure do
        feature_model "Feature"
      end
    end
    SuperHero = Class.new(ActiveRecord::Base)
    SuperHero.has_feature
  end

  # Called before each test
  before do
    FeatureRich::Engine.config.clear
    FeatureRich::Engine.features.clear
    FeatureRich::Engine.groups.clear
    @superman = SuperHero.new
    @superman.should be_an_instance_of SuperHero
    @superman.new_record?.should be_true
  end

  it "should create a has_many polymorphic relation" do
    SuperHero.reflections[:feature].should_not be_nil
    SuperHero.reflections[:feature].macro.should == :has_one
    SuperHero.reflections[:feature].options[:as].should == :featured
    SuperHero.reflections[:feature].options[:autosave].should be_true
  end

  it "should respond to #features" do
    g = FeatureRich::GroupFeature.new(:flying)
    FeatureRich::Engine.run do
      group :flying do
        feature :wings
      end
    end
    @superman.should respond_to(:features)
    @superman.features.should == FeatureRich::FeatureStruct.default
    @superman.features = [:fly]
    @superman.features.features.should == [:fly]
    @superman.feature.should be_an_instance_of FeatureRich::Feature
    @superman.feature.new_record?.should be_true
    @superman.name =  "Clark Kent"
    @superman.save!
    @superman.reload
    @superman.feature.should be_an_instance_of FeatureRich::Feature
    @superman.features.features.should == [:fly]
    @superman.features.group_features.should be_empty
    @superman.features = [:strong, g]
    @superman.changed?.should be_false
    @superman.save!
    @superman.reload
    @superman.features.features.should == [:strong]
    @superman.features.group_features.should == [:flying]
  end

  it "should respond to #has_feature?" do
    @superman.should respond_to(:has_feature?)
    @superman.has_feature?(:fly).should be_false
    @superman.features = [:fly]
    @superman.has_feature?(:fly).should be_true

    group = FeatureRich::GroupFeature.new(:flying)
    # Mocking is more convenient
    group.should_receive(:subset?).twice.and_return(false,true)
    @superman.has_feature?(group).should be_false
    @superman.has_feature?(group).should be_true
  end

  it "should respond to  #has_feature? with option group" do
    g = FeatureRich::GroupFeature.new(:flying)
    FeatureRich::Engine.run do
      group :flying do
        feature :wings
      end
      group :singing do
        feature :voice
      end
    end
    @superman.features = [:fly, g ]
    @superman.features.group_features.should == [:flying]
    @superman.has_feature?(:flying, :group => true).should be_true
    @superman.has_feature?(:singing, :group => true).should be_false
  end

  it "should have feature if group is disabled" do
    g = FeatureRich::GroupFeature.new(:flying, :disabled => true)
    FeatureRich::Engine.run do
      group :flying do
        feature :wings
      end
      group :singing do
        feature :voice
      end
    end
    @superman.features = [:fly, g ]
    @superman.features.group_features.should == [:flying]
    @superman.has_feature?(:flying, :group => true).should be_true
  end

  it "should have feature if Feature is disabled" do
    FeatureRich::Engine.run do
      feature :wings
      feature :voice, :disabled => true
    end
    @superman.features = [:fly ]
    @superman.features.features.should == [:fly]
    @superman.has_feature?(:voice).should be_true
  end

end
