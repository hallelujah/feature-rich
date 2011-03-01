module FeatureRich
  class GroupFeature

    attr_reader :name
    attr_accessor :sets

    def initialize(group_name)
      @name = group_name.to_sym
      @sets = []
    end

    def subset?(ary)
      (sets & ary) == sets
    end

    def feature(name)
      sets << name.to_sym
    end

    def configure(&block)
      instance_exec(&block)
      self
    end
    
  end
end
