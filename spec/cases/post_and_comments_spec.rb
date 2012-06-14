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

    (0..comments_number-1).each do |i|
      context "considering the comment #{i}" do
        subject { @comments[i] }

        its(:post_title) { should eq @post.title }
        its(:post_slug) { should eq @post.slug }
      end
    end

    context "when changing the post title" do
      before do
        @post.title = "A new title !"
        @post.save!
        @comments.each(&:reload)
      end

      (0..comments_number-1).each do |i|
        context "considering the comment #{i}" do
          subject { @comments[i] }

          its(:post_title) { should eq @post.title }
          its(:post_slug) { should eq @post.slug }
        end
      end
    end

    context "when destroying the post" do
      before do
        @post.destroy
        @comments.each(&:reload)
      end

      (0..comments_number-1).each do |i|
        context "considering the comment #{i}" do
          subject { @comments[i] }

          its(:post_title) { should be_nil }
          its(:post_slug) { should be_nil }
        end
      end
    end
  end

  context "when creating a comment without associating it" do
    before do
      @comment_only = Comment.create!
      @post.reload
    end

    subject { @comment_only }

    its(:post_title) { should be_nil }
    its(:post_slug) { should be_nil }

    context "when associating it" do
      before do
        @comment_only.post = @post
        @comment_only.save!
      end

      its(:post_title) { should eq @post.title }
      its(:post_slug) { should eq @post.slug }
    end

    context "when associating it (2nd way)" do
      before do
        @post.comments << @comment_only
        @comment_only.reload
      end

      its(:post_title) { should eq @post.title }
      its(:post_slug) { should eq @post.slug }
    end
  end

  context "when has a comment" do
    before do
      @comment = @post.comments.create!
    end

    subject { @comment }

    its(:post_title) { should eq @post.title }
    its(:post_slug) { should eq @post.slug }

    context "when associating the comment to another post" do
      before do
        @other_post = Post.create!(title: "Another title.")
        @comment.post = @other_post
        @comment.save
      end

      its(:post_title) { should eq @other_post.title }
      its(:post_slug) { should eq @other_post.slug }
    end
  end

end

