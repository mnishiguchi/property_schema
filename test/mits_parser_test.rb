require_relative "test_helper.rb"
require_relative "../lib/mits_parser/mits_parser.rb"

=begin
How to run this test:
  bundle exec guard
=end

describe MitsParser do

  let(:parsed_feed) do
    xml = File.read("#{Dir.pwd}/test/fixtures/files/feed_f.xml")
    rb_properties = from_xml(xml)["PhysicalProperty"]
  end

  let(:all_parsed_feeds) do
    pattern   = File.join(Dir.pwd, "test", "fixtures", "files", "feed_*.xml")
    filenames = Dir.glob(pattern)

    [].tap do |parsed_feeds|
      filenames.each do |file|
        parsed_feeds << from_xml(File.read(file))["PhysicalProperty"]
      end
    end
  end

  describe "---development---" do
    it "inspects things" do

      # # Check if Hash#dig statements are working.
      # all_parsed_feeds.each do |parsed_feed|
      #   ap !!parsed_feed.dig("Property", 0, "Floorplan", 0, "id")
      #   ap !!parsed_feed.dig("Property", 0, "File", 0, "id")
      #   puts '-' * 60
      # end

      puts
      all_parsed_feeds.each do |parsed_feed|
        MitsParser.parse(parsed_feed)
        puts '-' * 50
      end
    end
  end


  # TODO: More tests...


end
