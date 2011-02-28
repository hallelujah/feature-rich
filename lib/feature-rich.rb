require 'rubygems'
gem 'activerecord', '~> 2.3.2'
require 'activerecord'
require 'feature-rich/config'
require 'feature-rich/model_behaviour'
module FeatureRich
  VALID_KEYS = [:feature_model, :feature_table, :config_file]
  extend self

  mattr_accessor :config, :feature_table_name, :feature_handler_table_name

  self.config = Config.new

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


  def feature(name)
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

end
