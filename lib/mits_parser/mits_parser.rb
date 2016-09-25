# require "active_support/all"
# require "awesome_print"
# require "hashie"
# require "pry"


=begin
The MitsParser.parse method restructures a given piece of mits data into our
predetermined schema.
---
Usage:
  formatted_mits = MitsParser.parse(feed_xml)
  #==> Formatted array of hashes.
=end


module MitsParser

  def self.parse(data)

    # Determine the schema type.
    if has_files_nested_within_floorplan?(data)
      @parsed = ApartmentSchema::WithNestedFiles.new(data).parse
    elsif has_linked_files?(data)
      @parsed = ApartmentSchema::WithLinkedFiles.new(data).parse
    else
      @parsed = ApartmentSchema::Else.new(data).parse
    end
  end

  def self.has_files_nested_within_floorplan?(data)
    !!data.dig("Property", 0, "Floorplan", 0, "File") ||
    !!data.dig("Property", 0, "Floorplan", 0, "Slideshow") ||
    !!data.dig("Property", 0, "Floorplan", 0, "PhotoSet")
  end

  def self.has_linked_files?(data)
    !!data.dig("Property", 0, "Floorplan", 0, "id") &&
    !!data.dig("Property", 0, "File",      0, "id")
  end


  # ---
  # ---


  module ApartmentSchema
    class Base

      def initialize(data)

        puts "==> invoked: ApartmentSchema::Base"

        # Store the unprocessed feed data.
        @data = data

      end

      def parse
        puts "==> invoked: #parse"
        {
          raw_feed: @data
        }
      end
    end


    class WithNestedFiles < ApartmentSchema::Base
      def initialize(data)
        super

        puts "==> invoked: ApartmentSchema::WithNestedFiles"

      end
    end


    class WithLinkedFiles < ApartmentSchema::Base
      def initialize(data)
        super

        puts "==> invoked: ApartmentSchema::WithLinkedFiles"

      end
    end


    class Else < ApartmentSchema::Base
      def initialize(data)
        super

        puts "==> invoked: ApartmentSchema::Else"

      end
    end
  end
end


# ---
# ---


# TODO: Create a hash in our desired format.
#
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
