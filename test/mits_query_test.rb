require_relative "../lib/mits_parser/mits_query.rb"
require_relative "test_helper.rb"

=begin
How to run this test: bundle exec guard
=end

describe MitsQuery do

  let(:ash_property_data) do
    ash_path = File.join(FILE_DIR, "ash.xml")
    ash_xml = File.read(ash_path)
    Hash.from_xml(ash_xml)["PhysicalProperty"]
  end

  let(:boz_property_data) do
    boz_path = File.join(FILE_DIR, "boz.xml")
    boz_xml = File.read(boz_path)
    Hash.from_xml(boz_xml)["PhysicalProperty"]
  end


  # ===
  # ===


  describe "Property" do

    # A MitsQuery::Property object.
    let(:property) { MitsQuery::Properties.from(ash_property_data)[0] }

    describe "#address" do

      it "returns an info array" do
        assert property.address.is_a?(Array)
        assert /city/i  =~ property.address.to_s
        assert /state/i =~ property.address.to_s
      end
    end


    describe "#amenities" do

      it "returns an info array" do
        assert property.amenities.is_a?(Array)
        assert /amenit(y|ies)/i  =~ property.amenities.to_s
      end
    end
  end


  # TODO: other fields...



end
