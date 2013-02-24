# encoding: utf-8

class Song
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  has_many :ratings

  #denormalize :ratings, :note, :comment, count: true, mean: [:note]
  denormalize :ratings, :note, :comment, :upset_level, count: true
end
