# encoding: utf-8
module Mongoid
  module Max
    module Denormalize
      extend ActiveSupport::Concern

      included do

      end

      module ClassMethods

        def denormalize(relation, *fields)
          options = fields.extract_options!

          #TODO make all real fields if fields.empty?

#          puts "#relation : #{relation.inspect}"
#          puts "#fields   : #{fields.inspect}"
#          puts "#options  : #{options.inspect}"

          meta = self.relations[relation.to_s]
          raise ConfigError.new("Unknown relation", self, relation) if meta.nil?
#          puts "#        meta : #{meta.inspect}"

          inverse_meta = meta.klass.relations[meta.inverse.to_s]
          raise ConfigError.new("Unknown inverse relation", self, relation) if inverse_meta.nil?
#          puts "#inverse_meta : #{inverse_meta.inspect}"


          if meta.relation == Mongoid::Relations::Referenced::In && inverse_meta.relation == Mongoid::Relations::Referenced::Many
            OneToMany.new(self, meta, inverse_meta, fields, options).attach
          elsif meta.relation == Mongoid::Relations::Referenced::Many && inverse_meta.relation == Mongoid::Relations::Referenced::In
            ManyToOne.new(self, meta, inverse_meta, fields, options).attach
          else
            raise ConfigError.new("Relation not supported", self, relation)
          end

        end

        def mongoid3
          defined? Moped
        end
        def mongoid2
          defined? Mongo
        end

        def denormalize_update_all(conditions, updates)
          if mongoid3
            self.collection.find(conditions).update_all(updates)
          else
            self.collection.update(conditions, updates, :multi => true)
          end
        end

      end

    end
  end
end

