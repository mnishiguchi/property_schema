require "active_support/all"
require "awesome_print"
require "hashie"
require "pry"


class Hash
  include Hashie::Extensions::DeepFind
  include Hashie::Extensions::DeepLocate
end


=begin
The MitsParser.parse method restructures a given piece of mits data into our
predetermined schema.
---
Usage:
  formatted_mits = MitsParser.parse(feed_xml)
  #==> Formatted array of hashes.
=end
module MitsParser

  class << self

    def parse(data)
      return unless has_floorplan?(data)

      # Determine the schema type and parse the data with a corresponding parser.
      if is_type_01?(data)
        AttributeMapper::Type01.new(data).parse
      elsif is_type_02?(data)
        AttributeMapper::Type02.new(data).parse
      elsif is_type_03?(data)
        AttributeMapper::Type03.new(data).parse
      elsif is_type_04?(data)
        AttributeMapper::Type04.new(data).parse
      elsif is_type_05?(data)
        AttributeMapper::Type05.new(data).parse
      elsif is_type_06?(data)
        AttributeMapper::Type06.new(data).parse
      elsif is_type_07?(data)
        AttributeMapper::Type07.new(data).parse
      elsif is_type_08?(data)
        AttributeMapper::Type08.new(data).parse
      elsif is_type_09?(data)
        AttributeMapper::Type09.new(data).parse
      else
        AttributeMapper::Default.new(data).parse
      end
    end

    def is_type_01?(data)
      has_files_nested_within_floorplan?(data)

      # !!data.dig("Property", 0, "Identification", "Address") &&
      # !!data.dig("Property", 0, "Identification", "Phone") &&
      # !!data.dig("Property", 0, "Identification", "OfficeHour") &&
      # !!data.dig("Property", 0, "Information", "Fax") &&
      # !!data.dig("Property", 0, "Policy", "Pet") &&
      # !!data.dig("Property", 0, "Floorplan", 0, "Room") &&
      # !!data.dig("Property", 0, "Floorplan", 0, "Deposit") &&
      # !!data.dig("Property", 0, "Floorplan", 0, "Amenities") &&
      # !!data.dig("Property", 0, "Amenities", "Community") &&
      # !!data.dig("Property", 0, "Amenities", "Floorplan") &&
      # !!data.dig("Property", 0, "Amenities", "Community") &&
      # !!data.dig("Property", 0, "Amenities", "General") &&
      # !!data.dig("Property", 0, "File") &&
      # !!data.dig("Property", 0, "Policy", "Pet") &&
      # !!data.dig("Property", 0, "Amenities", "General")
    end

    def is_type_02?(data)
      has_linked_files?(data)
    end

    def is_type_03?(data)
    end

    def is_type_04?(data)
    end

    def is_type_05?(data)
    end

    def is_type_06?(data)
    end

    def is_type_07?(data)
    end

    def is_type_08?(data)
    end

    def is_type_09?(data)
    end


    # ---
    # ---


    def has_files_nested_within_floorplan?(data)
      !!data.dig("Property", 0, "Floorplan", 0, "File") ||
      !!data.dig("Property", 0, "Floorplan", 0, "Slideshow") ||
      !!data.dig("Property", 0, "Floorplan", 0, "PhotoSet")
    end

    def has_linked_files?(data)
      !!data.dig("Property", 0, "Floorplan", 0, "id") &&
      !!data.dig("Property", 0, "File",      0, "id")
    end

    def has_floorplan?(data)
      !!data.deep_find("Floorplan")
    end

    def has_floorplan_room?(data)
      !!data.dig("Property", 0, "Floorplan", 0, "Room")
    end

    def has_floorplan_deposit?(data)
      !!data.dig("Property", 0, "Floorplan", 0, "Deposit")
    end

    def has_information_officehour?(data)
      !!data.dig("Property", 0, "Information", 0, "OfficeHour")
    end

    def has_policy_pet?(data)
      !!data.dig("Property", 0, "Policy", "Pet")
    end

    def has_identification_generalid?
      !!data.dig("Property", 0, "Identification", "General_ID")
    end
  end


  # ---
  # ---


  module AttributeMapper
    class Base

      def initialize(data)
        return unless data

        puts "==> invoked: AttributeMapper::Base"

        # Store the unprocessed feed data.
        @data        = data
        @information = Array(data.deep_find_all("Information")) |
                       Array(data.deep_find_all("Identification")) |
                       Array(data.deep_find_all("OnSiteContact"))
        @amenities   = Array(data.deep_find_all("Amenities")) |
                       Array(data.deep_find_all("Utility"))
        @floorplan   = Array(data.deep_find_all("Floorplan"))
        @file        = Array(data.deep_find_all("File")) |
                       Array(data.deep_find_all("Slideshow")) |
                       Array(data.deep_find_all("PhotoSet"))
      end

      def parse

        puts "==> invoked: #parse"

        {
          # raw_feed:    @data,
          information: @information,
          amenities:   @amenities,
          floorplan:   @floorplan,
          file:        @file,
        }
      end
    end


    class Type01 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type01"

      end
    end


    class Type02 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type02"

      end
    end

    class Type03 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type03"

      end
    end

    class Type04 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type04"

      end
    end

    class Type05 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type05"

      end
    end

    class Type06 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type06"

      end
    end

    class Type07 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type07"

      end
    end

    class Type08 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type08"

      end
    end

    class Type09 < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Type09"

      end
    end

    class Default < AttributeMapper::Base
      def initialize(data)
        super

        puts "==> invoked: AttributeMapper::Default"

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
