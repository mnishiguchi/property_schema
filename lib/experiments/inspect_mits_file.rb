require "active_support/all"
require "awesome_print"
require 'nokogiri'
require 'yaml'

# Adopted from Rails
# http://apidock.com/rails/Hash/from_xml/class
def from_xml(xml, disallowed_types = nil)
  ActiveSupport::XMLConverter.new(xml, disallowed_types).to_h
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
raw_xml = File.read(file)
parsed_doc = Nokogiri.XML(raw_xml)

# ap uniq_xpaths(parsed_doc)

# ap parsed_doc.at_xpath("//File")
# ap parsed_doc.xpath("//File")[0].to_s
# ap !!parsed_doc.at_xpath("//Property/Floorplan") && !!parsed_doc.at_xpath("//Property/File")
# ap !!parsed_doc.xpath("//Property/File")[0].at_xpath("@id")
# ap !!parsed_doc.at_xpath("/File")
# ap !!parsed_doc.at_xpath("/Slideshow")
# ap !!parsed_doc.at_xpath("/PhotoSet")


# ---
# Obtain all the property hashes
# ---

#
# file = "#{Dir.pwd}/test/fixtures/files/feed_c.xml"
#
# raw_xml = File.read(file)
# rb_hash = Hash.from_xml(raw_xml)
#
# puts rb_hash.to_yaml


# =========================================================
# Read XML files
# =========================================================


# ---
# Examine xpaths
# ---


# def has_files_nested_within_floorplan?(parsed_doc)
#   !!parsed_doc.at_xpath("//Floorplan//File") ||
#   !!parsed_doc.at_xpath("//Floorplan//Slideshow") ||
#   !!parsed_doc.at_xpath("//Floorplan//PhotoSet")
# end
#
# def has_linked_files?(parsed_doc)
#   !!parsed_doc.xpath("//Property//Floorplan")[0]&.at_xpath("@id") &&
#   !!parsed_doc.xpath("//Property//File")[0]&.at_xpath("@id")
# end
#
#
# pattern   = File.join(Dir.pwd, "test", "fixtures", "files", "feed_*.xml")
# filenames = Dir.glob(pattern)
#
# xpaths   = []
#
# filenames.each do |file|
#   raw_xml = File.read(file)
#
#   # Parse raw_xml using Nokogiri.
#   parsed_doc = Nokogiri.XML(raw_xml)
#
#   xpaths << uniq_xpaths(parsed_doc)
#
#   # puts '=' * 30
#   # ap "has_files_nested_within_floorplan?: #{has_files_nested_within_floorplan?(parsed_doc)}"
#   # ap "has_linked_files?:                  #{has_linked_files?(parsed_doc)}"
#   # puts '=' * 30
# end


# ---
# Obtain all the property hashes
# ---


# pattern   = File.join(Dir.pwd, "test", "fixtures", "files", "feed_*.xml")
# filenames = Dir.glob(pattern)
#
# rb_array = []
#
# filenames.each do |file|
#   raw_xml = File.read(file)
#   rb_array << Hash.from_xml(raw_xml)
# end
