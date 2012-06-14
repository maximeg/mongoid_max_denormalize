# encoding: utf-8
module Mongoid
  module Max
    module Denormalize

      class Base

        attr_accessor :klass, :meta, :inverse_meta, :fields, :options

        def initialize(klass, meta, inverse_meta, fields, options)
          @klass = klass
          @meta = meta
          @inverse_meta = inverse_meta
          @fields = fields
          @options = options

          verify
        end

        def verify
          # There are fields
          raise ConfigError.new("Nothing to denormalize", klass, relation) if fields.empty? && options.empty?

          # All fields/methods are well defined
          fields.each do |field|
            unless meta.klass.instance_methods.include? field
              raise ConfigError.new("Unknown field or method :#{field}", klass, relation)
            end
          end

          # All options are allowed
          unless unallowed_options.empty?
            raise ConfigError.new("Unknown or not supported options :#{unallowed_options.first}", klass, relation)
          end
        end

        def allowed_options
          []
        end

        def unallowed_options
          options.keys - allowed_options
        end

        def relation
          @meta.name
        end
        def inverse_relation
          @meta.inverse
        end
        def inverse_klass
          @meta.klass
        end


        def fields_methods
          @fields_methods ||= fields.select do |field|
            meta.klass.fields[field.to_s].nil?
          end
        end
        def fields_only
          @fields_only ||= fields - fields_methods
        end

        class << self

          def array_code_for(fields)
            fields.map { |field| ":#{field}" }.join(", ")
          end

        end

      end

    end
  end
end

