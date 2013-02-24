# encoding: utf-8

class Contact
  include Mongoid::Document

  field :name, type: String

  has_many :addresses
end
