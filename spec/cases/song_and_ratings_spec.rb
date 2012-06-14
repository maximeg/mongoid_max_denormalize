# encoding: utf-8
require 'spec_helper'

#
# The case
#
class Rating
  include Mongoid::Document

  field :note, type: Integer
  field :comment, type: String
  field :upset_level, type: Integer

  belongs_to :song
end

class Song
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  has_many :ratings

  #denormalize :ratings, :note, :comment, count: true, mean: [:note]
  denormalize :ratings, :note, :comment, :upset_level, count: true
end


#
# The specs
#
describe "Case: a song and his ratings" do

  before do
    @song = Song.create!
  end

  context "when nothing" do
    context "considering the song" do
      subject { @song }

      it "should not have ratings" do
        @song.ratings.should be_empty
      end
    end
  end

  context "when adding a first rating (=5)" do
    before do
      @rating = @song.ratings.create!(note: 5, comment: "Good!")
      @song.reload
    end

    context "considering the song" do
      subject { @song }

      its(:ratings) { should have(1).rating }
      its(:ratings_count) { should eq 1 }
      its(:ratings_note) { should eq [5] }
      its(:ratings_comment) { should eq ["Good!"] }
      its(:ratings_upset_level) { should eq [] }

      context "when modifing the first rating (=4)" do
        before do
          @rating.note = 4
          @rating.upset_level = 0
          @rating.save!
          @song.reload
        end

        its(:ratings) { should have(1).rating }
        its(:ratings_count) { should eq 1 }
        its(:ratings_note) { should eq [4] }
        its(:ratings_comment) { should eq ["Good!"] }
        its(:ratings_upset_level) { should eq [0] }
      end

      context "when adding an other rating (=5)" do
        before do
          @other_rating = @song.ratings.create!(note: 5, comment: "Another good!")
          @song.reload
        end

        its(:ratings) { should have(2).rating }
        its(:ratings_count) { should eq 2 }
        its(:ratings_note) { should eq [5, 5] }
        its(:ratings_comment) { should eq ["Good!", "Another good!"] }

        context "when modifing the first rating (=4)" do
          before do
            @rating.note = 4
            @rating.save!
            @song.reload
          end

          its(:ratings_count) { should eq 2 }
          its(:ratings_note) { should eq [5, 4] }
          its(:ratings_comment) { should eq ["Good!", "Another good!"] }
        end

        context "when modifing the other rating (=4)" do
          before do
            @other_rating.note = 4
            @other_rating.save!
            @song.reload
          end

          its(:ratings_count) { should eq 2 }
          its(:ratings_note) { should eq [5, 4] }
          its(:ratings_comment) { should eq ["Good!", "Another good!"] }

          context "when modifing again the other rating (=3)" do
            before do
              @other_rating.note = 3
              @other_rating.comment = "Another good, again!"
              @other_rating.save!
              @song.reload
            end

            its(:ratings_count) { should eq 2 }
            its(:ratings_note) { should eq [5, 3] }
            its(:ratings_comment) { should eq ["Good!", "Another good, again!"] }
          end
        end

        context "when destroying the other rating" do
          before do
            @other_rating.destroy
            @song.reload
          end

          its(:ratings_count) { should eq 1 }
          its(:ratings) { should have(1).rating }
          its(:ratings_note) { should eq [5] }
          its(:ratings_comment) { should eq ["Good!"] }
        end
      end

      context "when creating a rating (=1) without associating it" do
        before do
          @rating_only = Rating.create!(note: 1, comment: "Bad")
          @song.reload
        end

        its(:ratings) { should have(1).rating }
        its(:ratings_count) { should eq 1 }
        its(:ratings_note) { should eq [5] }
        its(:ratings_comment) { should eq ["Good!"] }

        context "when associating it" do
          before do
            @rating_only.song = @song
            @rating_only.save!
            @song.reload
          end

          its(:ratings) { should have(2).rating }
          its(:ratings_count) { should eq 2 }
          its(:ratings_note) { should eq [5, 1] }
          its(:ratings_comment) { should eq ["Good!", "Bad"] }
        end

        context "when associating it (2nd way)" do
          before do
            @song.ratings << @rating_only
            @song.reload
          end

          its(:ratings) { should have(2).rating }
          its(:ratings_count) { should eq 2 }
          its(:ratings_note) { should eq [5, 1] }
          its(:ratings_comment) { should eq ["Good!", "Bad"] }
        end
      end

      context "when associating to another song" do
        before do
          @other_song = Song.create!
          @rating.song = @other_song
          @rating.save!
          @song.reload
        end

        its(:ratings) { should have(0).rating }
        its(:ratings_count) { should eq 0 }
        its(:ratings_note) { should eq [] }
        its(:ratings_comment) { should eq [] }

        context "considering the other song" do
          before do
            @other_song.reload
          end

          subject { @other_song }

          its(:ratings) { should have(1).rating }
          its(:ratings_count) { should eq 1 }
          its(:ratings_note) { should eq [5] }
          its(:ratings_comment) { should eq ["Good!"] }
        end
      end
    end
  end

end

