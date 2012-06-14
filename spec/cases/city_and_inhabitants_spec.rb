# encoding: utf-8
require 'spec_helper'

#
# The case
#
# This is to demonstrate when we denormalize a Many to One
# with no fields and only an option :count => true
#
class Inhabitant
  include Mongoid::Document

  belongs_to :city
end

class City
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  has_many :inhabitants

  denormalize :inhabitants, count: true
end


#
# The specs
#
describe "Case: a city and his inhabitants" do

  before do
    @city = City.create!
  end

  context "when nothing" do
    context "considering the city" do
      subject { @city }

      it "should not have inhabitants" do
        @city.inhabitants.should be_empty
        @city.inhabitants_count.should eq 0
      end
    end
  end

  context "when adding 20 inhabitants" do
    before do
      5.times do
        @city.inhabitants.create!
      end
      @city.reload
    end

    context "considering the city" do
      subject { @city }

      its(:inhabitants) { should have(5).inhabitants }
      its(:inhabitants_count) { should eq 5 }

      context "when destroying 2 inhabitants" do
        before do
          2.times do
            Inhabitant.first.destroy
          end
          @city.reload
        end

        its(:inhabitants) { should have(3).inhabitants }
        its(:inhabitants_count) { should eq 3 }
      end

      context "when destroying all inhabitants" do
        before do
          Inhabitant.destroy_all
          @city.reload
        end

        its(:inhabitants) { should have(0).inhabitant }
        its(:inhabitants_count) { should eq 0 }
      end
    end
  end

end

