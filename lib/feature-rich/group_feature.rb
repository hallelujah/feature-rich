module FeatureRich
  class GroupFeature

    attr_reader :name
    attr_accessor :sets, :label, :disabled

    def initialize(group_name, options = {})
      @name = group_name.to_sym
      @label = options[:label]
      @sets = []
      @disabled = !! options[:disabled]
    end


    def disabled?
     !! @disabled
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
