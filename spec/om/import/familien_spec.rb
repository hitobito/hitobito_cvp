require "spec_helper"

describe Import::Familien do

  let(:people) { Person.none }

  context "families" do
    subject  { described_class.new.families }

    it "is empty" do
      expect(subject).to be_empty
    end

    it "present but not valid for shared kundennummer" do
      Fabricate(:person, kundennummer: 1)
      Fabricate(:person, kundennummer: 1)
      expect(subject).to be_present
    end
  end

  context "valid families" do
    subject  { described_class.new.families.first }

    it "same address, same last_name" do
      Fabricate(:person, kundennummer: 1, address: "address", last_name: "last_name")
      Fabricate(:person, kundennummer: 1, address: "address", last_name: "last_name")
      Fabricate(:person, kundennummer: 1, address: "address", last_name: "last_name")
      expect(subject).not_to be_stale
      expect(subject).not_to be_valid
    end

    it "same address, same last_name, two genders set has stale member" do
      Fabricate(:person, kundennummer: 1, address: "address", last_name: "last_name")
      Fabricate(:person, kundennummer: 1, address: "address", last_name: "last_name", gender: :w)
      Fabricate(:person, kundennummer: 1, address: "address", last_name: "last_name", gender: :m)
      expect(subject).to be_stale
      expect(subject).to be_valid
    end
  end

  describe Import::Familien::Member do


    it "asdfasfd" do
      described_class.new
    end

  end

end
