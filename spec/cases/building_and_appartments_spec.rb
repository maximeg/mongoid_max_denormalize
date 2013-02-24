# encoding: utf-8
require 'spec_helper'

#
# The case
#
# This a circular dependency between 2 models that denormalize each other.
#
# Building & Appartment

#
# The specs
#

describe "Case: a building and his appartments" do

  before do
    @building = Building.create!(name: "Empire State Building")
  end

  context "when nothing" do
    context "considering the building" do
      subject { @building }

      its(:appartments) { should be_empty }
      its(:appartments_count) { should be_zero }
    end
  end

  context "when adding a first appartment" do
    before do
      @appartment = @building.appartments.create!
      @building.reload
    end

    context "considering the building" do
      subject { @building }

      its(:appartments) { should have(1).appartment }
      its(:appartments_count) { should eq(1) }
    end

    context "considering the appartment" do
      subject { @appartment }

      its(:building_name) { should eq @building.name }
      its(:building__type) { should eq @building._type }

      context "when changing the building name" do
        before do
          @building.name = "The Great Empire State Building"
          @building.save!
          @appartment.reload
        end

        its(:building_name) { should eq @building.name }
        its(:building__type) { should eq @building._type }
      end

      context "when destroying the building" do
        before do
          @building.destroy
          @appartment.reload
        end

        its(:building_name) { should be_nil }
        its(:building__type) { should be_nil }
      end
    end

    context "when adding a second appartment" do
      before do
        @appartment_2 = @building.appartments.create!
        @building.reload
      end

      context "considering the building" do
        subject { @building }

        its(:appartments) { should have(2).appartment }
        its(:appartments_count) { should eq(2) }
      end
    end

  end

end
