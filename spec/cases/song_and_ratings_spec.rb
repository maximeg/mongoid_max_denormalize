# encoding: utf-8
require 'spec_helper'

#
# The case
#
# Rating & Song


#
# The specs
#
describe "Case: a song and his ratings" do

  before do
    @song = Song.create!
  end

  context "when nothing" do
    it "Song should not have ratings" do
      @song.ratings.should be_empty
    end
  end

  context "when adding a first rating (=5)" do
    before do
      @rating = @song.ratings.create!(note: 5, comment: "Good!")
      @song.reload
    end

    context "considering the song" do
      subject { @song }

      it "denormalized fields should be set" do
        @song.ratings.should have(1).rating
        @song.ratings_count.should eq 1
        @song.ratings_note.should eq [5]
        @song.ratings_comment.should eq ["Good!"]
        @song.ratings_upset_level.should eq []
      end

      context "when modifing the first rating (=4)" do
        before do
          @rating.note = 4
          @rating.upset_level = 0
          @rating.save!
          @song.reload
        end

        it "denormalized fields should be set" do
          @song.ratings.should have(1).rating
          @song.ratings_count.should eq 1
          @song.ratings_note.should eq [4]
          @song.ratings_comment.should eq ["Good!"]
          @song.ratings_upset_level.should eq [0]
        end
      end

      context "when adding an other rating (=5)" do
        before do
          @other_rating = @song.ratings.create!(note: 5, comment: "Another good!")
          @song.reload
        end

        it "denormalized fields should be set" do
          @song.ratings.should have(2).rating
          @song.ratings_count.should eq 2
          @song.ratings_note.should eq [5, 5]
          @song.ratings_comment.should eq ["Good!", "Another good!"]
        end

        context "when modifing the first rating (=4)" do
          before do
            @rating.note = 4
            @rating.save!
            @song.reload
          end

          it "denormalized fields should be set" do
            @song.ratings_count.should eq 2
            @song.ratings_note.should eq [5, 4]
            @song.ratings_comment.should eq ["Good!", "Another good!"]
          end
        end

        context "when modifing the other rating (=4)" do
          before do
            @other_rating.note = 4
            @other_rating.save!
            @song.reload
          end

          it "denormalized fields should be set" do
            @song.ratings_count.should eq 2
            @song.ratings_note.should eq [5, 4]
            @song.ratings_comment.should eq ["Good!", "Another good!"]
          end

          context "when modifing again the other rating (=3)" do
            before do
              @other_rating.note = 3
              @other_rating.comment = "Another good, again!"
              @other_rating.save!
              @song.reload
            end

            it "denormalized fields should be set" do
              @song.ratings_count.should eq 2
              @song.ratings_note.should eq [5, 3]
              @song.ratings_comment.should eq ["Good!", "Another good, again!"]
            end
          end
        end

        context "when destroying the other rating" do
          before do
            @other_rating.destroy
            @song.reload
          end

          it "denormalized fields should be set" do
            @song.ratings_count.should eq 1
            @song.ratings.should have(1).rating
            @song.ratings_note.should eq [5]
            @song.ratings_comment.should eq ["Good!"]
          end
        end
      end

      context "when creating a rating (=1) without associating it" do
        before do
          @rating_only = Rating.create!(note: 1, comment: "Bad")
          @song.reload
        end

        it "denormalized fields should remain the same" do
          @song.ratings.should have(1).rating
          @song.ratings_count.should eq 1
          @song.ratings_note.should eq [5]
          @song.ratings_comment.should eq ["Good!"]
        end

        context "when associating it" do
          before do
            @rating_only.song = @song
            @rating_only.save!
            @song.reload
          end

          it "denormalized fields should be set" do
            @song.ratings.should have(2).rating
            @song.ratings_count.should eq 2
            @song.ratings_note.should eq [5, 1]
            @song.ratings_comment.should eq ["Good!", "Bad"]
          end
        end

        context "when associating it (2nd way)" do
          before do
            @song.ratings << @rating_only
            @song.reload
          end

          it "denormalized fields should be set" do
            @song.ratings.should have(2).rating
            @song.ratings_count.should eq 2
            @song.ratings_note.should eq [5, 1]
            @song.ratings_comment.should eq ["Good!", "Bad"]
          end
        end
      end

      context "when associating to another song" do
        before do
          @other_song = Song.create!
          @rating.song = @other_song
          @rating.save!
          @song.reload
        end

        it "denormalized fields should be set in old Song" do
          @song.ratings.should have(0).rating
          @song.ratings_count.should eq 0
          @song.ratings_note.should eq []
          @song.ratings_comment.should eq []
        end

        it "denormalized fields should be set in new Song" do
          @other_song.reload
          @other_song.ratings.should have(1).rating
          @other_song.ratings_count.should eq 1
          @other_song.ratings_note.should eq [5]
          @other_song.ratings_comment.should eq ["Good!"]
        end
      end
    end
  end

end
