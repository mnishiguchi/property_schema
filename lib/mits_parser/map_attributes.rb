require "active_support/all"
require "awesome_print"
require "hashie"
require "pry"

require_relative "mits_parser_helper.rb"

module MitsParser
  module MapAttributes
    class Base

      def initialize(feed_hash)
        return unless feed_hash

        puts "==> invoked: MapAttributes::Base"

        # Store the unprocessed feed feed_hash.
        @feed_hash   = feed_hash
        @information = Array(feed_hash.deep_find_all("Information")) |
                       Array(feed_hash.deep_find_all("Identification")) |
                       Array(feed_hash.deep_find_all("OnSiteContact"))
        @amenities   = Array(feed_hash.deep_find_all("Amenities")) |
                       Array(feed_hash.deep_find_all("Utility"))
        @floorplan   = Array(feed_hash.deep_find_all("Floorplan"))
        @file        = Array(feed_hash.deep_find_all("File")) |
                       Array(feed_hash.deep_find_all("Slideshow")) |
                       Array(feed_hash.deep_find_all("PhotoSet"))
      end

      # Create a property hash to be returned.
      # In a subclass, we can override the hash to suit the schema type.
      def parse

        puts "==> invoked: #parse"

        {
          # raw_feed:    @feed_hash,
          information: @information,
          amenities:   @amenities,
          floorplan:   @floorplan,
          file:        @file,
        }
      end
    end


    # ---
    # ---


    class Type01 < MapAttributes::Base
      def initialize(feed_hash)
        super

        puts "==> invoked: MapAttributes::Type01"

      end
    end

    class Type02 < MapAttributes::Base
      def initialize(feed_hash)
        super

        puts "==> invoked: MapAttributes::Type02"

      end
    end

    class Type03 < MapAttributes::Base
      def initialize(feed_hash)
        super

        puts "==> invoked: MapAttributes::Type03"

      end
    end

    class Default < MapAttributes::Base
      def initialize(feed_hash)
        super

        puts "==> invoked: MapAttributes::Default"

      end
    end
  end
end


# ---
# ---


# TODO: Create a hash in our desired format.
#
# {
#   :raw_hash     => @feed_hash,
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
