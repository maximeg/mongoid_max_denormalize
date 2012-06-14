# encoding: utf-8
module Mongoid
  module Max
    module Denormalize
      class ConfigError < ::StandardError

        def initialize(summary, klass, relation=nil)
          super("[%s.denormalize%s] %s" % [klass, relation && " :#{relation}", summary])
        end

      end
    end
  end
end

