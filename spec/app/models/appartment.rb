# encoding: utf-8

class Appartment
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  belongs_to :building

  denormalize :building, :name, :_type
end
