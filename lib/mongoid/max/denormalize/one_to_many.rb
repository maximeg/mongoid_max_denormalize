# encoding: utf-8
module Mongoid
  module Max
    module Denormalize

      class OneToMany < Base

        def attach

          fields.each do |field|
            field_meta = meta.klass.fields[field.to_s]
            klass.field "#{relation}_#{field}", type: field_meta.try(:type)
          end

          callback_code = <<EOM
            before_save :denormalize_from_#{relation}

            def denormalize_from_#{relation}
              return unless #{meta.key}_changed?

              fields = [#{Base.array_code_for(fields)}]
              if #{meta.key}.nil?
                fields.each do |field|
                  self.send(:"#{relation}_\#{field}=", nil)
                end
              else
                fields.each do |field|
                  self.send(:"#{relation}_\#{field}=", #{relation}.send(field))
                end
              end

              true
            end
EOM
          klass.class_eval callback_code

          callback_code = <<EOM
            around_save :denormalize_to_#{inverse_relation}

            def denormalize_to_#{inverse_relation}
              return unless changed?

              fields = [#{Base.array_code_for(fields)}]
              fields_only = [#{Base.array_code_for(fields_only)}]
              methods = [#{Base.array_code_for(fields_methods)}]
              changed_fields = fields_only & changed.map(&:to_sym)

              yield

              return if changed_fields.count == 0

              to_set = {}
              (changed_fields + methods).each do |field|
                to_set[:"#{relation}_\#{field}"] = send(field)
              end

              #{inverse_relation}.update to_set
            end

            around_destroy :denormalize_to_#{inverse_relation}_destroy

            def denormalize_to_#{inverse_relation}_destroy
              fields = [#{Base.array_code_for(fields)}]

              yield

              to_set = {}
              fields.each do |field|
                to_set[:"#{relation}_\#{field}"] = nil
              end

              #{inverse_relation}.update to_set
            end
EOM
          meta.klass.class_eval callback_code



        end

      end

    end
  end
end

