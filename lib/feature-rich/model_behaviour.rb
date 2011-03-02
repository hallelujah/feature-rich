module FeatureRich
  module ModelBehaviour

    def self.included(base)
      base.extend ClassMethods
    end # self.included

    module ClassMethods
      def has_feature
        has_one :feature, :as => :featured, :class_name => "FeatureRich::Feature", :autosave => true
        include InstanceMethods
      end
    end # ClassMethods

    module InstanceMethods

      def features
        _feature.content
      end

      def features=(ary)
        _feature.modify(ary)
      end

      def has_feature?(feature, options = {})
        with_group(feature, options[:group]) do |f|
          case f
          when Symbol, String
            features.features.include?(f.to_sym)
          when GroupFeature
            f.subset?(features.features) || features.group_features.include?(f.name)
          end
        end
      end

      protected

      def _feature
        (feature || build_feature(:content => FeatureStruct.default))
      end

      def with_group(name, with)
        if with
          feature = FeatureRich::Engine.groups[name]
        else
          feature = name
        end
        yield(feature) || false
      end

    end # InstanceMethods

  end
end
