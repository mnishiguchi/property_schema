require_relative "../lib/mits_parser/mits_parser.rb"
require_relative "test_helper.rb"

=begin
How to run this test: bundle exec guard
=end

describe MitsParser do

  let(:ash_mits_properties_data) do
    path = File.join(FILE_DIR, "ash.xml")
    xml  = File.read(path)
    data = Hash.from_xml(xml)["PhysicalProperty"]
  end

  let(:maa_mits_properties_data) do
    path = File.join(FILE_DIR, "maa.xml")
    xml  = File.read(path)
    data = Hash.from_xml(xml)["PhysicalProperty"]
  end

  let(:boz_mits_properties_data) do
    path = File.join(FILE_DIR, "boz.xml")
    xml  = File.read(path)
    data = Hash.from_xml(xml)["PhysicalProperty"]
  end

  describe "#new" do
    it "is a MitsQuery::Property" do
      assert MitsParser.new(ash_mits_properties_data).is_a?(MitsParser)
      assert MitsParser.new(boz_mits_properties_data).is_a?(MitsParser)
    end
  end

  describe "#parse" do
    let(:parsed) { MitsParser.new(ash_mits_properties_data).parse }
    # let(:parsed) { MitsParser.new(boz_mits_properties_data).parse }
    # let(:parsed) { MitsParser.new(maa_mits_properties_data).parse }

    it "is an array of hashes" do
      assert parsed.is_a?(Array)
      assert parsed[0].is_a?(Hash)

      ap parsed.first[:lease_length_min]

    end
  end


  # TODO: More tests...

end
