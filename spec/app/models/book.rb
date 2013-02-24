# encoding: utf-8

class Book
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  field :name, type: String

  def slug
    name.try(:parameterize)
  end

  belongs_to :author

  has_many :reviews
end
