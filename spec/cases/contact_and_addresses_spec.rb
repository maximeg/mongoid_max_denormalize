# encoding: utf-8
require 'spec_helper'

#
# The case
#
# Contact, Person & Address


#
# The specs
#
describe "Case: a contact and his addresses" do

  before do
    @person = Person.create!(name: "John Doe")
  end

  context "when nothing" do
    context "considering the person" do
      subject { @person }

      its(:addresses) { should be_empty }
    end
  end

  context "when adding a first address" do
    before do
      @address = @person.addresses.create!
    end

    context "considering the person" do
      subject { @person }

      its(:addresses) { should have(1).address }
    end

    context "considering the address" do
      subject { @address }

      its(:contact_name) { should eq @person.name }
      its(:contact__type) { should eq @person._type }

      context "when changing the person name" do
        before do
          @person.name = "John Doe Jr."
          @person.save!
          @address.reload
        end

        its(:contact_name) { should eq @person.name }
        its(:contact__type) { should eq @person._type }
      end

      context "when destroying the person" do
        before do
          @person.destroy
          @address.reload
        end

        its(:contact_name) { should be_nil }
        its(:contact__type) { should be_nil }
      end
    end
  end

end
