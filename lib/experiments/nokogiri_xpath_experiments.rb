require "awesome_print"
require 'nokogiri'


# Read an xml file from the specified path and returns the parsed xml document.
def load_xml(file_path)
  # Read the source XML file.
  puts "file_path: #{file_path}"
  raw_xml = File.read(file_path)

  # Parse raw_xml using Nokogiri.
  parsed_doc = Nokogiri.XML(raw_xml)
end


# Obtains XPATHs.
# http://stackoverflow.com/a/15692699/3837223
def uniq_xpaths(parsed_doc)
  xpaths = []
  parsed_doc.xpath('//*[child::* and not(child::*/*)]').each { |node| xpaths << node.path }
  xpaths.each { |path| path.gsub!(/\[\d*\]/, "[]") }.uniq!
end


# =========================================================
# Read a single XML file
# =========================================================


file_path  = "#{Dir.pwd}/test/fixtures/files/feed_c.xml"
parsed_doc = load_xml(file_path)
# ap uniq_xpaths(parsed_doc)

# ap parsed_doc.at_xpath("//File")
# ap parsed_doc.xpath("//File")[0].to_s
# ap !!parsed_doc.at_xpath("//Property/Floorplan") && !!parsed_doc.at_xpath("//Property/File")
# ap !!parsed_doc.xpath("//Property/File")[0].at_xpath("@id")
# ap !!parsed_doc.at_xpath("/File")
# ap !!parsed_doc.at_xpath("/Slideshow")
# ap !!parsed_doc.at_xpath("/PhotoSet")


# =========================================================
# Read XML files
# =========================================================


def has_files_nested_in_property?(parsed_doc)
  !!parsed_doc.at_xpath("//Property//File") ||
  !!parsed_doc.at_xpath("//Property//Slideshow") ||
  !!parsed_doc.at_xpath("//Property//PhotoSet")
end

def has_linked_files?(parsed_doc)
  !!parsed_doc.xpath("//Property/Floorplan")[0]&.at_xpath("@id") &&
  !!parsed_doc.xpath("//Property/File")[0]&.at_xpath("@id")
end


pattern   = File.join(Dir.pwd, "test", "fixtures", "files", "feed_*.xml")
filenames = Dir.glob(pattern)

xpaths = []

filenames.each do |file|
  parsed_doc = load_xml(file)
  xpaths << uniq_xpaths(parsed_doc)

  puts '=' * 30
  ap "has_files_nested_in_property?: #{has_files_nested_in_property?(parsed_doc)}"
  ap "has_linked_files?:             #{has_linked_files?(parsed_doc)}"
  puts '=' * 30
end
