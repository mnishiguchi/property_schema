require "active_support/all"
require "awesome_print"

# Adopted from Rails
# http://apidock.com/rails/Hash/from_xml/class
def from_xml(xml, disallowed_types = nil)
  ActiveSupport::XMLConverter.new(xml, disallowed_types).to_h
end


=begin
A MitsParser object restructures a given piece of mits data into our
predetermined schema.
---
Usage:
  formatted_mits = MitsParser.new(feed_xml).parse
  #==> Formatted array of hashes.
=end

class MitsParser

  def initialize(feed_xml)

    # Parse the XML data.
    parsed_doc = Nokogiri::XML(feed_xml)

    # Determine the schema.
    if has_files_nested_within_floorplan?(parsed_doc)
      @parsed = ApartmentSchema::WithNestedFiles.new(feed_xml).parse
    elsif has_linked_files?(parsed_doc)
      @parsed = ApartmentSchema::WithLinkedFiles.new(feed_xml).parse
    else
      @parsed = ApartmentSchema::Else.new(feed_xml).parse
    end
  end

  def parse
    @parsed
  end

  def has_files_nested_within_floorplan?(parsed_doc)
    !!parsed_doc.at_xpath("//Floorplan//File") ||
    !!parsed_doc.at_xpath("//Floorplan//Slideshow") ||
    !!parsed_doc.at_xpath("//Floorplan//PhotoSet")
  end

  def has_linked_files?(parsed_doc)
    !!parsed_doc.xpath("//Property/Floorplan")[0]&.at_xpath("@id") &&
    !!parsed_doc.xpath("//Property/File")[0]&.at_xpath("@id")
  end
end


# ---
# ---


module ApartmentSchema
  class Base
    attr_reader :properties

    def initialize(parsed_doc)

      puts "==> invoked: ApartmentSchema::Base"

      @properties = from_xml(parsed_doc)

    end

    def parse
      puts "==> invoked: #parse"
      {
        properties: @properties
      }
    end
  end

  class WithNestedFiles < ApartmentSchema::Base
    def initialize(parsed_doc)
      super

      puts "==> invoked: ApartmentSchema::WithNestedFiles"

    end
  end

  class WithLinkedFiles < ApartmentSchema::Base
    def initialize(parsed_doc)
      super

      puts "==> invoked: ApartmentSchema::WithLinkedFiles"

    end
  end

  class Else < ApartmentSchema::Base
    def initialize(parsed_doc)
      super

      puts "==> invoked: ApartmentSchema::Else"

    end
  end
end

# Create a hash in our desired format.
# {
#   :raw_hash     => @data,
#
#   ## Has One to Has One
#   # Feed Attributes
#   :name         => name,
#   :email        => email,
#   :url          => url,
#   :phone        => phone,
#   :description  => description,
#
#   # :floorplans   => floorplans,
#
#   :latitude     => latitude,
#   :longitude    => longitude,
#   :address      => address["Address"],
#   :city         => address["City"],
#   :po_box       => address["PO_Box"],
#   :county       => address["County"],
#   :state        => address["State"],
#   :zip          => address["Zip"],
#   :country      => address["Country"],
#
#   :lease_length_min => lease_length["Min"],
#   :lease_length_max => lease_length["Max"],
#
#   ## Has Many to Has Many
#   # Selectively Ignored Attributes
#   :amenities    => amenities,
#   :photos       => photos,
#   :utilities    => utilities,
# }
