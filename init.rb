require 'feature-rich'
# Ok let's go
config.after_initialize do
  FeatureRich::Engine.load!
  FeatureRich::Engine.config.config_file ||= Rails.root.join('config/feature-rich.rb').to_s
  FeatureRich::Engine.run do
    eval(File.read(FeatureRich::Engine.config.config_file))
  end
end
