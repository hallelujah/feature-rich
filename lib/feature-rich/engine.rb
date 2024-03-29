require 'rubygems'
gem 'activerecord', '~> 2.3.2'
require 'activerecord'
require 'feature-rich/config'
require 'feature-rich/model_behaviour'
require 'feature-rich/group_feature'

module FeatureRich
  module Engine
    VALID_KEYS = [:feature_model, :feature_table, :config_file]

    mattr_accessor :config, :feature_table_name, :feature_handler_table_name, :features, :groups

    self.config = Config.new

    self.groups = HashWithIndifferentAccess.new
    self.features = Set.new


    class << self # Class Proxy
      def configure(conf = Config.new, &block)
        conf.instance_exec(&block)
        self.config.merge!(conf)
        self.config.assert_valid_keys(*VALID_KEYS)
        self.config
      end

      def run(&block)
        instance_exec(&block)
        bootstrap!
      end

      def load!
        if Object.const_defined?(:Rails) && Rails.root
          self.config.config_file ||= Rails.root.join('config/feature-rich.rb').to_s
        end
        run do
          eval(File.read(self.config.config_file))
        end
      end

      def feature(name, options = {})
        group(:_none_) do
          feature name, options
        end
      end

      def group(name, opts = {}, &block)
        group = (self.groups[name.to_sym] || FeatureRich::GroupFeature.new(name, opts)).configure(&block)
        self.features += group.sets
        self.groups[name.to_sym] = group
      end

      private

      def bootstrap!
        set_feature_table_name
        set_feature_handler_table_name
        ActiveRecord::Base.__send__ :include, FeatureRich::ModelBehaviour
      end

      def set_feature_handler_table_name
        feature_table_name = config.feature_table || table_name(config.feature_model)
      end

      def set_feature_table_name
        feature_table_name = config.feature_table || table_name(config.feature_model)
      end

      def table_name(name)
        ActiveRecord::Base.__send__ :undecorated_table_name, name
      end
    end # Class Proxy

  end
end
