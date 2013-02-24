# encoding: utf-8

class Rating
  include Mongoid::Document

  field :note, type: Integer
  field :comment, type: String
  field :upset_level, type: Integer

  belongs_to :song
end
