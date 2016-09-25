require_relative "test_helper.rb"
require_relative "support/active_support"

require_relative "../lib/mits_parser/mits_parser.rb"

=begin
How to run this test: bundle exec guard
=end

describe MitsParser do

  let(:properties) do
    xml = File.read("#{Dir.pwd}/test/fixtures/files/feed_f.xml")
    rb_properties = from_xml(xml)["PhysicalProperty"]
  end

  describe "---development---" do
    it "inspects things" do

      ap !!properties.dig("Property", 0, "File")

      # puts
      # all_feed_xml_files.each do |xml_file|
      #   MitsParser.new(xml_file).parse
      #
      #   puts '-' * 50
      # end
    end
  end


  # TODO: More tests...

end
