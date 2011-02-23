require 'rubygems'
gem 'activerecord', '~> 2.3.2'
require 'activerecord'
require 'feature-rich/config'
module FeatureRich
  extend self

  mattr_accessor :config
  self.config = Config.new

  def configure(conf = self.config, &block)
    conf.instance_exec(&block)
    config
  end

  def run(conf = Config.new,&block)
    configure(conf,&block)
    self.config.merge!(conf)
    bootstrap!
  end
  
  private

  def bootstrap!
  end

end
