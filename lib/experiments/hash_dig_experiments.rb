require "active_support/all"
require "awesome_print"
require "json"

# Check currently working directory.
puts "Dir.pwd:  #{Dir.pwd}"

# The path to the 'files' directory
FILE_DIR = "#{Dir.pwd}/test/fixtures/files"

# The absolute path to the source XML file.
path = File.join(FILE_DIR, "ash_property.json")
puts "path: #{path}"

# Read that file.
json = File.read(path)

# Convert json to hash using JSON.parse
hash = JSON.parse(json)
ap hash

puts
puts "keys: #{hash.keys}"
puts
ap hash.dig "Identification"
