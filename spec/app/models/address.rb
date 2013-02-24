# encoding: utf-8

class Address
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  belongs_to :contact

  denormalize :contact, :name, :_type
end
