# encoding: utf-8

class Inhabitant
  include Mongoid::Document

  belongs_to :city
end
