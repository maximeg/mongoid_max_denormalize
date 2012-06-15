# encoding: utf-8
require 'spec_helper'

#
# The case
#
class Post
  include Mongoid::Document

  field :title, type: String

  def slug
    title.try(:parameterize)
  end

  has_many :comments
end

class Comment
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  belongs_to :post

  denormalize :post, :title, :slug
end

#
# The specs
#
describe "Case: a post and his comments" do

  before do
    @post = Post.create!(title: "A good title !")
  end

  context "when nothing" do
    context "considering the post" do
      subject { @post }

      its(:comments) { should be_empty }
    end
  end

  comments_number = 2
  context "when adding #{comments_number} comments" do
    before do
      @comments = []
      comments_number.times do
        @comments << @post.comments.create!
      end
    end

    context "considering the post" do
      subject { @post }

      its(:comments) { should have(comments_number).comment }
    end

    it "denormalized fields should be set" do
      @comments.each do |comment|
        comment.post_title.should eq @post.title
        comment.post_slug.should eq @post.slug
      end
    end

    context "when changing the post title" do
      before do
        @post.title = "A new title !"
        @post.save!
        @comments.each(&:reload)
      end

      it "denormalized fields should be set" do
        @comments.each do |comment|
          comment.post_title.should eq @post.title
          comment.post_slug.should eq @post.slug
        end
      end
    end

    context "when destroying the post" do
      before do
        @post.destroy
        @comments.each(&:reload)
      end

      it "denormalized fields should be set" do
        @comments.each do |comment|
          comment.post_title.should be_nil
          comment.post_slug.should be_nil
        end
      end
    end
  end

  context "when creating a comment without associating it" do
    before do
      @comment_only = Comment.create!
      @post.reload
    end

    it "denormalized fields should be nil" do
      @comment_only.post_title.should be_nil
      @comment_only.post_slug.should be_nil
    end

    context "when associating it" do
      before do
        @comment_only.post = @post
        @comment_only.save!
      end

      it "denormalized fields should be set" do
        @comment_only.post_title.should eq @post.title
        @comment_only.post_slug.should eq @post.slug
      end
    end

    context "when associating it (2nd way)" do
      before do
        @post.comments << @comment_only
        @comment_only.reload
      end

      it "denormalized fields should be set" do
        @comment_only.post_title.should eq @post.title
        @comment_only.post_slug.should eq @post.slug
      end
    end
  end

  context "when has a comment" do
    before do
      @comment = @post.comments.create!
    end

    it "denormalized fields should be set" do
      @comment.post_title.should eq @post.title
      @comment.post_slug.should eq @post.slug
    end

    context "when associating the comment to another post" do
      before do
        @other_post = Post.create!(title: "Another title.")
        @comment.post = @other_post
        @comment.save
      end

      it "denormalized fields should be set" do
        @comment.post_title.should eq @other_post.title
        @comment.post_slug.should eq @other_post.slug
      end
    end
  end

end

