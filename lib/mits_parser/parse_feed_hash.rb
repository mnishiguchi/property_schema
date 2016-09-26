require "active_support/all"
require "awesome_print"
require "hashie"
require "pry"

require_relative "mits_parser_helper.rb"
require_relative "map_attributes.rb"

=begin
The MitsParser.parse method restructures a given piece of mits feed_hash into our
predetermined schema.
---
Usage:
  formatted_mits = MitsParser.parse(feed_xml)
  #==> Formatted array of hashes.
=end
module MitsParser

  class ParseFeedHash

    class << self
      
      # This is the interface with the rest of our application.
      # - param feed_hash - a single hash that wraps a whole feed, which typically
      # has the "Property" key.
      # - return -  an array of property hashes that are formatted in our schema.
      def parse(feed_hash)

        # Determine an appropriate MapAttributes for the passed-in feed_hash
        # and delegate the parsing to it.
        puts "No floorplan exists" unless has_property_floorplan?(feed_hash)

        if has_property_information?(feed_hash) || has_property_identification?(feed_hash)
          if has_files_nested_within_floorplan?(feed_hash)
            MapAttributes::Type01.new(feed_hash).parse
          elsif has_linked_files?(feed_hash)
            MapAttributes::Type02.new(feed_hash).parse
          else
            MapAttributes::Type03.new(feed_hash).parse
          end
        else
          MapAttributes::Default.new(feed_hash).parse
        end
      end


      # ---
      # Utility methods for detecting the existence of keys.
      # ---


      def has_files_nested_within_floorplan?(feed_hash)
        !!feed_hash.dig("Property", 0, "Floorplan", 0, "File") ||
        !!feed_hash.dig("Property", 0, "Floorplan", 0, "Slideshow") ||
        !!feed_hash.dig("Property", 0, "Floorplan", 0, "PhotoSet")
      end

      def has_linked_files?(feed_hash)
        !!feed_hash.dig("Property", 0, "Floorplan", 0, "id") &&
        !!feed_hash.dig("Property", 0, "File",      0, "id")
      end

      def has_property_floorplan?(feed_hash)
        !!feed_hash.dig("Property", 0, "Floorplan")
      end

      def has_property_nearbycommunity?(feed_hash)
        !!feed_hash.dig("Property", 0, "NearbyCommunity")
      end

      def has_property_information?(feed_hash)
        !!feed_hash.dig("Property", 0, "Information")
      end

      def has_property_identification?(feed_hash)
        !!feed_hash.dig("Property", 0, "Identification") ||
        !!feed_hash.dig("Property", 0, "PropertyID", "Identification")
      end

      def has_property_policy?(feed_hash)
        !!feed_hash.dig("Property", 0, "Policy")
      end

      def has_property_policy_pet?(feed_hash)
        !!feed_hash.dig("Property", 0, "Policy", "Pet")
      end

      def has_property_onsitecontact?(feed_hash)
        !!feed_hash.dig("Property", 0, "OnSiteContact")
      end

      def has_property_acounting?(feed_hash)
        !!feed_hash.dig("Property", 0, "Accounting")
      end

      def has_property_payment?(feed_hash)
        !!feed_hash.dig("Property", 0, "Accounting")
      end

      def has_property_building?(feed_hash)
        !!feed_hash.dig("Property", 0, "Building")
      end

      def has_property_fee?(feed_hash)
        !!feed_hash.dig("Property", 0, "Fee")
      end

      def has_property_concession?(feed_hash)
        !!feed_hash.dig("Property", 0, "Concession")
      end

      def has_property_ilsidentification?(feed_hash)
        !!feed_hash.dig("Property", 0, "ILS_Identification")
      end

      def has_property_amenities?(feed_hash)
        !!feed_hash.dig("Property", 0, "Amenities")
      end

      def has_property_utility?(feed_hash)
        !!feed_hash.dig("Property", 0, "Utility")
      end
    end
  end
end
