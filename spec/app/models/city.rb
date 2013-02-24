# encoding: utf-8

class City
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  has_many :inhabitants

  denormalize :inhabitants, count: true
end
