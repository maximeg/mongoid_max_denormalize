# encoding: utf-8
module Mongoid
  module Max
    module Denormalize

      class ManyToOne < Base

        def verify
          super

          unless fields_methods.empty?
            raise ConfigError.new("Methods denormalization not supported for Many to One", klass, relation)
          end
        end

        def attach
          #
          # This side of the relation
          #
          fields_only.each do |field|
            klass.field "#{relation}_#{field}", type: Array, default: []
          end

          if has_count?
            klass.field "#{relation}_count", type: Integer, default: 0
          end

          klass.before_create :"denormalize_from_#{relation}"

          klass.class_eval <<-EOM, __FILE__, __LINE__
            def denormalize_from_#{relation}(force=false)
              #{relation}_retrieved = nil

              fields = [#{Base.array_code_for(fields_only)}]
              unless fields.empty?
                #{relation}_retrieved = #{relation}.unscoped.to_a
                if #{relation}_retrieved.count > 0
                  fields.each do |field|
                    self.send(:"#{relation}_\#{field}=", #{relation}_retrieved.map(&field).compact)
                  end
                end
              end

              if #{has_count?}
                self.#{relation}_count = #{relation}_retrieved.nil? ? #{relation}.unscoped.count : #{relation}_retrieved.count
              end

              true
            end
          EOM

          klass.class_eval <<-EOM, __FILE__, __LINE__
            def self.denormalize_from_#{relation}!
              all.entries.each do |obj|
                obj.denormalize_from_#{relation}(true)
                obj.save!
              end

              nil
            end
          EOM

          #
          # Other side of the relation
          #
          inverse_klass.around_save :"denormalize_to_#{inverse_relation}"

          inverse_klass.class_eval <<-EOM, __FILE__, __LINE__
            def denormalize_to_#{inverse_relation}
              if !changed? && !new_record?
                yield if block_given?
                return
              end

              was_new = new_record?
              was_added = false
              was_removed = false

              fields = [#{Base.array_code_for(fields_only)}]

              remote_id = send(:#{inverse_meta.key})

              to_rem = {}
              to_add = {}
              if #{inverse_meta.key}_changed?
                changed_fields = fields
                if !#{inverse_meta.key}.nil? && !#{inverse_meta.key}_was.nil?
                  was_added = true
                  changed_fields.each do |field|
                    to_add[:"#{relation}_\#{field}"] = send(field)
                  end
                  denormalize_to_#{inverse_relation}_old
                else
                  if #{inverse_meta.key}_was.nil?
                    was_added = true
                    changed_fields.each do |field|
                      to_add[:"#{relation}_\#{field}"] = send(:"\#{field}_changed?") ? send(field) : send(:"\#{field}_was")
                    end
                  else
                    was_removed = true
                    remote_id = send(:#{inverse_meta.key}_was)
                    changed_fields.each do |field|
                      to_rem[:"#{relation}_\#{field}"] = send(:"\#{field}_changed?") ? send(:"\#{field}_was") : send(field)
                    end
                  end
                end
              elsif #{inverse_meta.key}.nil?
                changed_fields = []
              else
                changed_fields = fields & changed.map(&:to_sym)
                changed_fields.each do |field|
                  to_rem[:"#{relation}_\#{field}"] = send(:"\#{field}_was")
                  to_add[:"#{relation}_\#{field}"] = send(field)
                end
              end

              yield if block_given?
              return if (changed_fields.empty? && !fields.empty?)

              to_update = { "$set" => {}, "$inc" => {}, "$push" => {} }
              to_get = {}

              to_rem_fields = to_rem.reject {|k,v| v.nil?}.keys
              to_add_fields = to_add.reject {|k,v| v.nil?}.keys

              # Those to add only
              (to_add_only_fields = to_add_fields - to_rem_fields).each do |field|
                to_update["$push"][field] = to_add[field]
              end

              to_set_fields = (to_add_fields + to_rem_fields - to_add_only_fields).uniq

              to_get.merge! Hash[to_set_fields.map{ |f| [f, 1] }] unless to_set_fields.empty?

              obj = #{klass}.collection.find("$query" => {:_id => remote_id}, "$only" => to_get).first unless to_get.empty?

              to_set_fields.each do |field|
                array = obj[field.to_s] || []

                if to_rem_fields.include? field
                  (i = array.index(to_rem[field])) and array.delete_at(i)
                end
                if to_add_fields.include? field
                  array << to_add[field]
                end

                to_update["$set"][field] = array
              end

              to_update["$inc"][:#{relation}_count] = 1 if #{has_count?} && (was_new || was_added)
              to_update["$inc"][:#{relation}_count] = -1 if #{has_count?} && (was_removed)

              to_update.reject! {|k,v| v.empty?}
              #{klass}.denormalize_update_all({:_id => remote_id}, to_update) unless to_update.empty?
            end
          EOM

          inverse_klass.class_eval <<-EOM, __FILE__, __LINE__
            def denormalize_to_#{inverse_relation}_old
              fields = [#{Base.array_code_for(fields_only)}]

              remote_id = send(:#{inverse_meta.key}_was)

              to_rem = {}
              fields.each do |field|
                to_rem[:"#{relation}_\#{field}"] = send(:"\#{field}_was")
              end

              to_update = { "$set" => {}, "$inc" => {}, "$push" => {} }
              to_get = {}

              to_rem_fields = to_rem.reject {|k,v| v.nil?}.keys

              to_set_fields = to_rem_fields

              to_get.merge! Hash[to_set_fields.map{ |f| [f, 1] }] unless to_set_fields.empty?

              obj = #{klass}.collection.find("$query" => {:_id => remote_id}, "$only" => to_get).first unless to_get.empty?

              to_set_fields.each do |field|
                array = obj[field.to_s] || []

                if to_rem_fields.include? field
                  (i = array.index(to_rem[field])) and array.delete_at(i)
                end

                to_update["$set"][field] = array
              end

              to_update["$inc"][:#{relation}_count] = -1 if #{has_count?}

              to_update.reject! {|k,v| v.empty?}
              #{klass}.denormalize_update_all({:_id => remote_id}, to_update) unless to_update.empty?
            end
          EOM


          inverse_klass.around_destroy :"denormalize_to_#{inverse_relation}_destroy"

          inverse_klass.class_eval <<-EOM, __FILE__, __LINE__
            def denormalize_to_#{inverse_relation}_destroy
              fields = [#{Base.array_code_for(fields)}]

              remote_id = send(:#{inverse_meta.key})

              to_rem = {}
              fields.each do |field|
                to_rem[:"#{relation}_\#{field}"] = send(field)
              end

              yield if block_given?

              to_update = { "$set" => {}, "$inc" => {}, "$push" => {} }
              to_get = {}

              to_rem_fields = to_rem.reject {|k,v| v.nil?}.keys

              to_get.merge! Hash[to_rem_fields.map{ |f| [f, 1] }]
              obj = #{klass}.collection.find("$query" => {:_id => remote_id}, "$only" => to_get).first unless to_get.empty?

              to_rem_fields.each do |field|
                array = obj[field.to_s] || []

                if to_rem_fields.include? field
                  (i = array.index(to_rem[field])) and array.delete_at(i)
                end

                to_update["$set"][field] = array
              end

              to_update["$inc"][:#{relation}_count] = -1 if #{has_count?}

              to_update.reject! {|k,v| v.empty?}
              #{klass}.denormalize_update_all({:_id => remote_id}, to_update) unless to_update.empty?
            end
          EOM
        end

        def allowed_options
          super + [:count]
        end

        def has_count?
          !options[:count].nil?
        end

      end

    end
  end
end

