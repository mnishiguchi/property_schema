require "active_support/all"
require "awesome_print"

# Adopted from Rails
# http://apidock.com/rails/Hash/from_xml/class
def from_xml(xml, disallowed_types = nil)
  ActiveSupport::XMLConverter.new(xml, disallowed_types).to_h
end

# Check currently working directory.
puts "Dir.pwd:  #{Dir.pwd}"

# The path to the 'files' directory
FILE_DIR = "#{Dir.pwd}/test/fixtures/files"

# The absolute path to the source XML file.
path = File.join(FILE_DIR, "maa.xml")
puts "path: #{path}"

# Read that file.
xml = File.read(path)

# Convert xml to hash using ActiveSupport::XMLConverter
hash = Hash.from_xml(xml)
# ap hash

# Extract desired info from the resulting hash.
info_hash = hash["PhysicalProperty"]["Property"][0]["File"].first


ap info_hash.keys


# # Convert the info to JSON
# info_json = info_hash.to_json
#
# # Write the info to a new file.
# # destination = "tmp.json"
# # destination = "maa_property_0_file_0.json"
# path = File.join(FILE_DIR, destination)
# File.write(path, info_json)
