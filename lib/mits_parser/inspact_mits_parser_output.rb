require "active_support/all"
require "awesome_print"
require "nokogiri"
require "pry"

# The path to the source ruby hash file. Contains 71 properties.
file_path = File.join(Dir.pwd, "mits_parser_output_20160919.rb")
puts "file_path: #{file_path}"

# Read that file.
serialized = File.read(file_path)

# Evaluate it into a usable hash.
parsed_property_array = eval(serialized)


# ---
# Examine the data.
# ---


ap parsed_property_array[0][:photo_urls]


# ---
# Examine the paths
# ---


# Take one property and make a list of paths.
xml_document = Nokogiri.XML(parsed_property_array.first.to_xml)

# Obtains XPATHs.
# http://stackoverflow.com/a/15692699/3837223
def uniq_xpaths(xml_document)
  xpaths = []
  xml_document.xpath('//*[child::* and not(child::*/*)]').each { |node| xpaths << node.path }
  xpaths.each { |path| path.gsub!(/\[\d*\]/, "[]") }.uniq!.sort!
  xpaths.each { |path| path.gsub!(/\A\/hash/, "") }
end

# ap uniq_xpaths(xml_document)


=begin
----------------------------
# All the top level keys
----------------------------
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
