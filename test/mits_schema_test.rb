require 'nokogiri'
require_relative "../lib/mits_schema/mits_schema.rb"
require_relative "test_helper.rb"

=begin
How to run this test: bundle exec guard
=end


def all_feed_xml_files
  pattern   = File.join(Dir.pwd, "test", "fixtures", "files", "feed_*.xml")
  filenames = Dir.glob(pattern)

  [].tap do |xml_files|
    filenames.each do |file|
      xml_files << File.read(file)
    end
  end
end


describe MitsSchema do

  let(:raw_xml) do
    file       = "#{Dir.pwd}/test/fixtures/files/feed_c.xml"
    raw_xml    = File.read(file)
  end

  decribe ".from_xml" do
    
  end
  it "TODO" do
    all_feed_xml_files.each do |raw_xml|
      MitsSchema.from_xml(raw_xml)
    end
  end

  # TODO: More tests...

end
