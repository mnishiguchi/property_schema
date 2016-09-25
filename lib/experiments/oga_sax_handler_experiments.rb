require "oga"
require "awesome_print"

# Check currently working directory.
puts "Dir.pwd:  #{Dir.pwd}"

# absolute path to the source XML file.
filename = "#{Dir.pwd}/test/fixtures/files/ash_a.xml"
puts "filename: #{filename}"

# Read that file.
xml = File.read(filename)


class SaxHandler
  def on_element(namespace, name, attrs = {})
    puts name
  end
end

handler = SaxHandler.new
parser  = Oga::XML::SaxParser.new(handler, xml)
doc = parser.parse

ap doc
