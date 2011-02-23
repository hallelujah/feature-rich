require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FeatureRich::Config instance" do
  before do
    @config = FeatureRich::Config.new
  end

  it "should return \"Feature\" as default feature_model" do
    @config.feature_model.should == "Feature"
  end

  it "should pass arguments like standard method" do
    @config.feature_model "OtherModel"
    @config.feature_model.should == "OtherModel"
  end

end
