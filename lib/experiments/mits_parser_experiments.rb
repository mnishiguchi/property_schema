require "active_support/all"
require "awesome_print"
require "json"

require_relative "../mits_parser/mits_parser.rb"

# Adopted from Rails
# http://apidock.com/rails/Hash/from_xml/class
def from_xml(xml, disallowed_types = nil)
  ActiveSupport::XMLConverter.new(xml, disallowed_types).to_h
end

def fetch_xml
  # Check currently working directory.
  # puts "Dir.pwd:  #{Dir.pwd}"

  # The path to the 'files' directory
  file_dir = "#{Dir.pwd}/test/fixtures/files"

  # The absolute path to the source XML file.
  path = File.join(file_dir, "ash.xml")
  puts "file: #{path}"

  # Read that file.
  xml = File.read(path)
end

xml = fetch_xml

# Convert xml to hash using ActiveSupport::XMLConverter
hash = Hash.from_xml(xml)
# ap hash

ap MitsParser.parse_properties(hash["PhysicalProperty"]).size #==> 7

=begin
# ap MitsParser.parse_properties(hash["PhysicalProperty"]).first.keys

$ ruby lib/experiments/mits_parser_experiments.rb
file: /Users/masa/projects/ruby/parse_xml/test/fixtures/files/ash.xml
[
    [ 0] :raw_hash,
    [ 1] :floorplans,
    [ 2] :unique_feed_identifiers,
    [ 3] :longitude,
    [ 4] :latitude,
    [ 5] :names,
    [ 6] :urls,
    [ 7] :emails,
    [ 8] :phones,
    [ 9] :descriptions,
    [10] :information,
    [11] :office_hours,
    [12] :photo_urls,
    [13] :pet_policy,
    [14] :promotional_info,
    [15] :amenities,
    [16] :utilities,
    [17] :parking,
    [18] :address,
    [19] :city,
    [20] :county,
    [21] :zip,
    [22] :po_box,
    [23] :country,
    [24] :state,
    [25] :lease_length_min,
    [26] :lease_length_max
]
=end
