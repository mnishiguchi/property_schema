require "active_support/all"
require "awesome_print"
require "pry"
require "recursive_open_struct"

# Adopted from Rails
# http://apidock.com/rails/Hash/from_xml/class
def from_xml(xml, disallowed_types = nil)
  ActiveSupport::XMLConverter.new(xml, disallowed_types).to_h
end

# The path to the source XML file.
file_path = File.join("#{Dir.pwd}/test/fixtures/files", "maa.xml")
puts "file_path: #{file_path}"

# Read that file.
xml = File.read(file_path)

# Convert xml to hash using ActiveSupport::XMLConverter
hash = Hash.from_xml(xml)
# ap hash

ros = RecursiveOpenStruct.new(hash)

binding.pry

puts "end of file"
