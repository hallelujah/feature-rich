module FeatureRich
  class GroupFeature < FeatureRich::FeatureHandler

    attr_accessor :sets

    def initialize(group_name, options = {})
      super
      @sets = []
    end

    def subset?(ary)
      (names & ary) == names
    end

    def names
      sets.map(&:name)
    end

    def feature(name, options = {})
      sets << FeatureRich::FeatureHandler.new(name.to_sym, options)
    end

    def configure(&block)
      instance_exec(&block)
      self
    end
    
  end
end
