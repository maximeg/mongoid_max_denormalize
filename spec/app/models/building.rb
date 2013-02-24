# encoding: utf-8

class Building
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  field :name, type: String

  has_many :appartments

  denormalize :appartments, count: true
end
