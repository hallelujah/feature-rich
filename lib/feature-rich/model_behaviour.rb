module FeatureRich
  module ModelBehaviour

    def self.included(base)
      base.extend ClassMethods
    end # self.included

    module ClassMethods
      def has_feature
        has_one :feature, :as => :featured
        include InstanceMethods
      end
    end # ClassMethods

    module InstanceMethods

      def features
        feature ? feature.features : []
      end

      def features=(ary)
        if feature 
          feature.features = ary 
        else
          build_feature(:features => ary)
        end
      end

      def has_feature?(feature)
        case feature
        when Symbol, String
          features.include?(feature.to_sym)
        when GroupFeature
          feature.subset?(features)
        end
      end

    end # InstanceMethods

  end
end
