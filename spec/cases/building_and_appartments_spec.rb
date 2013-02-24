# encoding: utf-8
require 'spec_helper'

#
# The case
#
# This a circular dependency between 2 models that denormalize each other.
#
# Building, Skyscraper & Appartment

#
# The specs
#

describe "Case: a skyscraper and his appartments" do

  before do
    @skyscraper = Skyscraper.create!(name: "Empire State Skyscraper")
  end

  context "when nothing" do
    context "considering the skyscraper" do
      subject { @skyscraper }

      its(:appartments) { should be_empty }
      its(:appartments_count) { should be_zero }
    end
  end

  context "when adding a first appartment" do
    before do
      @appartment = @skyscraper.appartments.create!
      @skyscraper.reload
    end

    context "considering the skyscraper" do
      subject { @skyscraper }

      its(:appartments) { should have(1).appartment }
      its(:appartments_count) { should eq(1) }
    end

    context "considering the appartment" do
      subject { @appartment }

      its(:building_name) { should eq @skyscraper.name }
      its(:building__type) { should eq @skyscraper._type }

      context "when changing the skyscraper name" do
        before do
          @skyscraper.name = "The Great Empire State Skyscraper"
          @skyscraper.save!
          @appartment.reload
        end

        its(:building_name) { should eq @skyscraper.name }
        its(:building__type) { should eq @skyscraper._type }
      end

      context "when destroying the skyscraper" do
        before do
          @skyscraper.destroy
          @appartment.reload
        end

        its(:building_name) { should be_nil }
        its(:building__type) { should be_nil }
      end
    end

    context "when adding a second appartment" do
      before do
        @appartment_2 = @skyscraper.appartments.create!
        @skyscraper.reload
      end

      context "considering the skyscraper" do
        subject { @skyscraper }

        its(:appartments) { should have(2).appartment }
        its(:appartments_count) { should eq(2) }
      end
    end

  end

end
