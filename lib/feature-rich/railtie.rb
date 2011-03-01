require 'rails'
require 'feature-rich'
module FeatureRich
  class Railtie < Rails::Railtie

    config.feature_rich = FeatureRich::Engine.config
    config.feature_rich.config_file = Rails.root.join('config/feature-rich.rb').to_s

    initializer "feature-rich.after_initialize" do |app|
      FeatureRich::Engine.run do
        eval(File.read(app.config.feature_rich.config_file))
      end
    end
  end
end
