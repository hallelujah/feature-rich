require 'feature-rich'
FeatureRich::Engine.config.config_file = Rails.root.join('config/feature-rich.rb').to_s
# Ok let's go
config.after_initialize do
  FeatureRich::Engine.run do
    eval(File.read(FeatureRich::Engine.config.config_file))
  end
end
