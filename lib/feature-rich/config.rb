module FeatureRich
  class Config < ActiveSupport::OrderedOptions
    def initialize(*args)
      super(*args)
      self.feature_model ||= "Feature"
    end


    def method_missing(name, *args)
      if args.size == 1 && name.to_s !~ /=$/
        super("#{name}=",*args)
      else
        super(name, *args)
      end
    end
  end
end
