module FeatureRich
  class FeatureHandler

    attr_reader :name
    attr_accessor :label, :disabled

    def initialize(name, options = {})
      @name = name.to_sym
      @label = options[:label]
      @disabled = !! options[:disabled]
    end

    def disabled?
      !! @disabled
    end

  end
end
