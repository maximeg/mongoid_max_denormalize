# encoding: utf-8
require 'spec_helper'

#
# The case
#
# City & Inhabitant



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

      it "count should be 0" do
        @city.inhabitants.should be_empty
        @city.inhabitants_count.should eq 0
      end
    end
  end

  inhabitants_number = 5
  context "when adding #{inhabitants_number} inhabitants" do
    before do
      inhabitants_number.times do
        @city.inhabitants.create!
      end
      @city.reload
    end

    context "considering the city" do
      subject { @city }

      it "count should be #{inhabitants_number}" do
        @city.inhabitants.should have(inhabitants_number).inhabitants
        @city.inhabitants_count.should eq inhabitants_number
      end

      context "when destroying 2 inhabitants" do
        before do
          2.times do
            Inhabitant.first.destroy
          end
          @city.reload
        end

        it "count should be #{inhabitants_number - 2}" do
          @city.inhabitants.should have(inhabitants_number - 2).inhabitants
          @city.inhabitants_count.should eq(inhabitants_number - 2)
        end
      end

      context "when destroying all inhabitants" do
        before do
          Inhabitant.destroy_all
          @city.reload
        end

        it "count should be 0" do
          @city.inhabitants.should be_empty
          @city.inhabitants_count.should eq 0
        end
      end
    end
  end

end
