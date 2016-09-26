require "active_support/all"
require "awesome_print"
require "nokogiri"
require "pry"


def load_all_feed_xml
  xml_docs = []
  xml_files = File.join("**", "*.xml")
  Dir.glob(xml_files).each do |path|
    xml_docs << Nokogiri.XML(File.read(path))
  end

  xml_docs
end

# Obtains XPATHs.
# http://stackoverflow.com/a/15692699/3837223
def uniq_xpaths(xml_document)
  xpaths = []
  xml_document.xpath('//*[child::* and not(child::*/*)]').each { |node| xpaths << node.path }
  xpaths.each { |path| path.gsub!(/\[\d*\]/, "[]") }.uniq!.sort!
  xpaths.each { |path| path.gsub!(/\A\/hash/, "") }
end


# ---
# ---


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


# ap parsed_property_array[0][:photo_urls]


# ---
# Examine the paths
# ---


# Take one property and make a list of paths.
xml_document = Nokogiri.XML(parsed_property_array.first.to_xml)

# ap uniq_xpaths(xml_document)


# ---
# Examine the paths for all the xml files
# ---


# ap load_all_feed_xml.size


paths = []
load_all_feed_xml.each do |xml_document|
  paths << uniq_xpaths(xml_document).each { |path| path.gsub!(/\/PhysicalProperty/, "") }
end.flatten.uniq

ap paths


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


----------------------------
# All the paths
----------------------------
[
    [ 0] "/amenities",
    [ 1] "/descriptions",
    [ 2] "/emails",
    [ 3] "/floorplans/floorplan[]/descriptions",
    [ 4] "/floorplans/floorplan[]/raw-hash/Amenities",
    [ 5] "/floorplans/floorplan[]/raw-hash/Deposit",
    [ 6] "/floorplans/floorplan[]/raw-hash/MarketRent",
    [ 7] "/floorplans/floorplan[]/raw-hash/Room/Room[]",
    [ 8] "/floorplans/floorplan[]/raw-hash/SquareFeet",
    [ 9] "/floorplans/floorplan[]/unique-feed-identifiers",
    [10] "/information",
    [11] "/names",
    [12] "/office-hours/friday",
    [13] "/office-hours/monday",
    [14] "/office-hours/saturday",
    [15] "/office-hours/sunday",
    [16] "/office-hours/thursday",
    [17] "/office-hours/tuesday",
    [18] "/office-hours/wednesday",
    [19] "/pet-policy/specifics",
    [20] "/phones/identification-phone-array",
    [21] "/raw-hash/Amenities/Community",
    [22] "/raw-hash/Amenities/Floorplan",
    [23] "/raw-hash/Amenities/General/General[]",
    [24] "/raw-hash/File/File[]/id",
    [25] "/raw-hash/Floorplan/Floorplan[]/Amenities",
    [26] "/raw-hash/Floorplan/Floorplan[]/Deposit",
    [27] "/raw-hash/Floorplan/Floorplan[]/MarketRent",
    [28] "/raw-hash/Floorplan/Floorplan[]/Room/Room[]",
    [29] "/raw-hash/Floorplan/Floorplan[]/SquareFeet",
    [30] "/raw-hash/Identification/Address",
    [31] "/raw-hash/Identification/Fax",
    [32] "/raw-hash/Identification/Phone",
    [33] "/raw-hash/Information/OfficeHour/OfficeHour[]",
    [34] "/raw-hash/Policy/Pet",
    [35] "/unique-feed-identifiers"
]
=end
