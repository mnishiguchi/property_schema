require 'nokogiri'

require_relative "../lib/mits_parser/mits_parser.rb"
require_relative "test_helper.rb"

=begin
How to run this test: bundle exec guard
=end

describe MitsParser do

  let(:single_xml_file) do
    File.read("#{Dir.pwd}/test/fixtures/files/feed_f.xml")
  end

  let(:all_feed_xml_files) do
    pattern   = File.join(Dir.pwd, "test", "fixtures", "files", "feed_*.xml")
    filenames = Dir.glob(pattern)

    [].tap do |xml_files|
      filenames.each do |file|
        xml_files << File.read(file)
      end
    end
  end


  # describe "#parse" do
  #   let(:parsed) { MitsParser.new(single_xml_file).parse }
  #
  #   it "is an array of hashes" do
  #
  #     # TODO
  #   end
  # end

  describe "---development---" do
    it "inspects things" do
      puts
      all_feed_xml_files.each do |xml_file|
        MitsParser.new(xml_file).parse

        puts '-' * 50
      end
    end
  end


  # TODO: More tests...

end
