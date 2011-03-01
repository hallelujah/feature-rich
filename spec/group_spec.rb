require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe FeatureRich::GroupFeature do
  before do
    @group = FeatureRich::GroupFeature.new(:a_group)
  end

  it "should respond to #new with a name" do
    FeatureRich::GroupFeature.should respond_to(:new).with(1)
  end

  it "should define a instance attribute reader :name" do
    @group.should respond_to(:name)
    @group.name.should be_an_instance_of(Symbol)
  end

  it "should define instance attribute accessor :sets" do
    @group.should respond_to(:sets)
    @group.should respond_to(:sets=)
    @group.sets.should == Array.new
  end

  it "should respond to #configure" do
    @group.should respond_to(:configure).with(0)
    lambda do
      @group.configure do
        feature :black_color
        feature :full_face
      end
    end.should_not raise_exception
  end

  it "should respond to #subset?" do
    @group.should respond_to(:subset?)
    @group.configure do
      feature :red
      feature :blue
      feature :green
    end
    @group.subset?([:red, :green, :blue, :orange]).should be_true
    @group.subset?([:red, :black]).should be_false
  end
end
