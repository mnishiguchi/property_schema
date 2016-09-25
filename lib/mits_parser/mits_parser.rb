require "active_support/all"
require "awesome_print"
require "hashie"
require "pry"


=begin
A MitsParser object restructures a given piece of mits data into our
predetermined schema.
---
Usage:
  formatted_mits = MitsParser.new(feed_xml).parse
  #==> Formatted array of hashes.
=end

class MitsParser

  def initialize(parsed_feed)

    puts MitsParser.dig("Array")

    # Determine the schema.
    if has_files_nested_within_floorplan?(parsed_feed)
      @parsed = ApartmentSchema::WithNestedFiles.new(parsed_feed).parse
    elsif has_linked_files?(parsed_feed)
      @parsed = ApartmentSchema::WithLinkedFiles.new(parsed_feed).parse
    else
      @parsed = ApartmentSchema::Else.new(parsed_feed).parse
    end
  end

  def parse
    @parsed
  end

  def has_files_nested_within_floorplan?(parsed_feed)
    # !!parsed_feed.at_xpath("//Floorplan//File") ||
    # !!parsed_feed.at_xpath("//Floorplan//Slideshow") ||
    # !!parsed_feed.at_xpath("//Floorplan//PhotoSet")
  end

  def has_linked_files?(parsed_feed)
    # !!parsed_feed.xpath("//Property/Floorplan")[0]&.at_xpath("@id") &&
    # !!parsed_feed.xpath("//Property/File")[0]&.at_xpath("@id")
  end


  # =======================================================
  # Utility class methods
  # =======================================================


  def self.dig_any(hash, default_value, *paths)
    paths.each do |paths|
      result = MitsParser.dig(hash, paths)
      result = result.compact.flatten if result.is_a?(Array)
      next if result.blank?
      return result
    end
    default_value
  end


  # Retrieves the value object of the specified paths. If the specified path
  # contains an array, travarses and search on all the elements.
  # - param data - hash, array or string
  # - param paths - unlimited arrays of strings ["", ""], ["", ""]
  # - return a hash of path => value
  def self.dig_all(hash, *paths)
    raise ArgumentError.new("paths must be an array") unless paths.is_a?(Array)

    {}.tap do |results|
      paths.each do |paths|
        result = MitsParser.dig(hash, paths)
        result = result.compact.flatten if result.is_a?(Array)
        next if result.blank?
        results[paths.join.underscore.to_sym] = result
      end
    end
  end


  # Retrieves the value object of the specified path. If the specified path
  # contains an array, travarses and search on all the elements.
  # - param data - a hash, array or string
  # - param path - an array of ["path", "to", "node"]
  # - return value if any datatype
  # ---
  # NOTE: This method does something similar to what Hash#dig does but
  # the difference is this method proceed recursively even if the path contains
  # arrays.
  def self.dig(data, path)
    raise ArgumentError.new("path must be an array") unless path.is_a?(Array)

    return data if path.empty?  # Base case

    # Pop a node from the path list.
    current_node, remaining_path = path[0], path[1..-1]

    # Continue the process according to the current condition.
    if current_node == "Array"
      # Recurse on all the nodes in the array.
      data.map { |h| MitsParser.dig(h, remaining_path) }
    elsif data.is_a?(Hash) && (new_data = data[current_node])
      # Recurse on the remaining path.
      MitsParser.dig(new_data, remaining_path)
    else
      []
    end
  end


  # Try freaking everything...ensures we pick up some weird keys in Floorplan
  def self.brute_force_keys(key)
    [key.singularize, key.pluralize].map do |r|
      [r.titleize, r.camelize, r.underscore, r.tableize, r.humanize]
    end.flatten.uniq
  end



end


# ---
# ---


module ApartmentSchema
  class Base
    attr_reader :properties

    def initialize(parsed_feed)

      puts "==> invoked: ApartmentSchema::Base"

      @properties = from_xml(parsed_feed)

    end

    def parse
      puts "==> invoked: #parse"
      {
        properties: @properties
      }
    end
  end

  class WithNestedFiles < ApartmentSchema::Base
    def initialize(parsed_feed)
      super

      puts "==> invoked: ApartmentSchema::WithNestedFiles"

    end
  end

  class WithLinkedFiles < ApartmentSchema::Base
    def initialize(parsed_feed)
      super

      puts "==> invoked: ApartmentSchema::WithLinkedFiles"

    end
  end

  class Else < ApartmentSchema::Base
    def initialize(parsed_feed)
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
