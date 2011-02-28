require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/db_helper')

describe FeatureRich::ModelBehaviour do
  before(:all) do
    FeatureRich.run do
      configure do
        feature_model "Feature"
      end
    end
    SuperHero = Class.new(ActiveRecord::Base)
    SuperHero.has_feature
    Feature = Class.new(ActiveRecord::Base)
    Feature.belongs_to :featured, :polymorphic => true
    Feature.serialize :features, Array
  end

  before do
    @superman = SuperHero.new
    @superman.should be_an_instance_of SuperHero
    @superman.new_record?.should be_true
  end

  it "should create a has_many polymorphic relation" do
    SuperHero.reflections[:feature].should_not be_nil
    SuperHero.reflections[:feature].macro.should == :has_one
    SuperHero.reflections[:feature].options[:as].should == :featured
  end

  it "should respond to #features" do
    @superman.should respond_to(:features)
    @superman.features.should == []
    @superman.features = [:fly]
    @superman.features.should == [:fly]
    @superman.feature.should be_an_instance_of Feature
    @superman.feature.new_record?.should be_true
    @superman.name =  "Clark Kent"
    @superman.save!
    @superman.reload
    @superman.feature.should_not == []
    @superman.feature.should be_an_instance_of Feature
    @superman.features.should == [:fly]
    @superman.features = [:fly, :strong]
    @superman.save!
    @superman.reload
    @superman.features.should == [:fly, :strong]
  end

end
