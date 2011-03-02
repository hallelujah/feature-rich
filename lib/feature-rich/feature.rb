module FeatureRich
  FeatureStruct = Struct.new(:features, :group_features)
  FeatureStruct.class_eval do
    def initialize(f,g)
      self.features = []
      self.group_features = []
      super
    end

    def modify(ary)
      self.features = ary.grep(Symbol)
      self.group_features = ary.grep(GroupFeature){|g| g.name.to_sym }
    end

    def self.default
      new([],[])
    end
  end

  class Feature < ActiveRecord::Base
    belongs_to :featured, :polymorphic => true
    serialize :content, FeatureStruct

    before_save :symbolize_feature_name

    def after_initialize
      self.content ||= FeatureStruct.default
    end

    def modify(ary)
      content_will_change!
      content.modify(ary)
    end

    protected

    def symbolize_feature_name
      content.features.map!(&:to_sym)
      content.group_features.map!(&:to_sym)
    end
  end
end
