# encoding: utf-8
module Mongoid
  module Max
    module Denormalize
      class ConfigError < ::StandardError

        def initialize(summary, klass)
          super("[#{klass}.denormalize] #{summary}")
        end

      end
    end
  end
end

