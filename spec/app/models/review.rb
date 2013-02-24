# encoding: utf-8

class Review
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  belongs_to :book

  field :rating, type: Integer
end
