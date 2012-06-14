# encoding: utf-8
require 'spec_helper'

#
# The case
#
class Author
  include Mongoid::Document

  field :name, type: String

  has_many :books
end

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

class Review
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  belongs_to :book

  field :rating, type: Integer
end

def reload!
  [@author, @book, @review_1, @review_2].each(&:reload)
end

#
# The specs
#
describe "Case: Existing models" do
  before(:each) do
    @author = Author.create!(name: "Michael Crichton")
    @book = Book.create!(name: "Jurassic Park", author: @author)
    @review_1 = Review.create!(book: @book, rating: 4)
    @review_2 = Review.create!(book: @book, rating: 5)

    reload!
  end

  context "when defining the denormalization for Authors in Books" do
    before { Book.denormalize :author, :name }

    it "Authors denormalized fields should fill" do
      @book.author_name.should be_nil

      Author.denormalize_to_books!
      reload!

      @book.author_name.should eq("Michael Crichton")
    end
  end

  context "when defining the denormalization for Books in Reviews" do
    before { Review.denormalize :book, :name, :slug }

    it "Books denormalized fields should fill" do
      [@review_1, @review_2].each do |review|
        review.book_name.should be_nil
        review.book_slug.should be_nil
      end

      Book.denormalize_to_reviews!
      reload!

      [@review_1, @review_2].each do |review|
        review.book_name.should eq("Jurassic Park")
        review.book_slug.should eq("jurassic-park")
      end
    end
  end

  context "when defining the denormalization for Reviews in Books" do
    before { Book.denormalize :reviews, :rating, :count => true }

    it "Reviews denormalized fields should fill" do
      @book.reviews_count.should be_nil
      @book.reviews_rating.should be_nil

      Book.denormalize_from_reviews!
      reload!

      @book.reviews_count.should eq 2
      @book.reviews_rating.should eq [4, 5]
    end
  end

end

