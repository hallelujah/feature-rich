require 'feature-rich'
# Ok let's go
config.after_initialize do
  FeatureRich::Engine.load!
end
