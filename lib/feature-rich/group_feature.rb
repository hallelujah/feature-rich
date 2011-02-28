module FeatureRich
  class GroupFeature

    def self.configure(&block)

    end

    def initialize(group_name)
    end

    def subset?(ary)
      (features & ary) == features
    end
    
  end
end
