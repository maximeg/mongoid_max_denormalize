# encoding: utf-8
module Mongoid
  module Max
    module Denormalize

      class OneToMany < Base

        def attach
          #
          # This side of the relation
          #
          fields.each do |field|
            field_meta = inverse_klass.fields[field.to_s]
            klass.field "#{relation}_#{field}", type: field_meta.try(:type)
          end

          klass.before_save :"denormalize_from_#{relation}"

          klass.class_eval <<-EOM, __FILE__, __LINE__
            def denormalize_from_#{relation}
              return true unless #{meta.key}_changed?

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

          #
          # Other side of the relation
          #
          inverse_klass.around_save :"denormalize_to_#{inverse_relation}"

          inverse_klass.class_eval <<-EOM, __FILE__, __LINE__
            def denormalize_to_#{inverse_relation}(force = false)
              unless changed? || force
                yield if block_given?
                return
              end

              fields = [#{Base.array_code_for(fields)}]
              fields_only = [#{Base.array_code_for(fields_only)}]
              methods = [#{Base.array_code_for(fields_methods)}]
              changed_fields = force ? fields_only.dup : (fields_only & changed.map(&:to_sym))

              yield if block_given?

              return if changed_fields.count == 0

              to_set = {}
              (changed_fields + methods).each do |field|
                to_set[:"#{relation}_\#{field}"] = send(field)
              end

              #{inverse_relation}.update_all(to_set) unless to_set.empty?
            end
          EOM

          inverse_klass.class_eval <<-EOM, __FILE__, __LINE__
            def self.denormalize_to_#{inverse_relation}!
              all.entries.each do |obj|
                obj.denormalize_to_#{inverse_relation}(true)
              end

              nil
            end
          EOM


          inverse_klass.around_destroy :"denormalize_to_#{inverse_relation}_destroy"

          inverse_klass.class_eval <<-EOM, __FILE__, __LINE__
            def denormalize_to_#{inverse_relation}_destroy
              fields = [#{Base.array_code_for(fields)}]

              yield if block_given?

              to_set = {}
              fields.each do |field|
                to_set[:"#{relation}_\#{field}"] = nil
              end

              #{inverse_relation}.update_all(to_set) unless to_set.empty?
            end
          EOM
        end

      end

    end
  end
end

