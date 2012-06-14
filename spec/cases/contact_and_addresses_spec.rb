# encoding: utf-8
require 'spec_helper'

#
# The case
#
class Contact
  include Mongoid::Document

  field :name, type: String

  has_many :addresses
end

class Person < Contact
end

class Address
  include Mongoid::Document
  include Mongoid::Max::Denormalize

  belongs_to :contact

  denormalize :contact, :name
end

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

      context "when changing the person name" do
        before do
          @person.name = "John Doe Jr."
          @person.save!
          @address.reload
        end

        its(:contact_name) { should eq @person.name }
      end

      context "when destroying the person" do
        before do
          @person.destroy
          @address.reload
        end

        its(:contact_name) { should be_nil }
      end
    end
  end

end

