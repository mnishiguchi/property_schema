=begin
The MitsQueryFinders module provides a set of utility methods for us to use
for searching for a piece of property data at a given key or path.
=end

module MitsQueryFinders
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
  end

  module ClassMethods
    ARRAY_NODE = "Array"

    # Retrieves the value object of the specified paths.
    # data - hash, array or string
    # default_value
    # paths - an array of string arrays [["", ""], ["", ""]]
    # returns the value of the first occurrence if any.
    def find_first_by_paths(data, *paths)
      paths.each do |path|
        result = self.find_by_path(data, path)
        result = result.compact.flatten if result.is_a?(Array)
        return result unless result.blank?
      end
      nil
    end


    # Retrieves the value object of the specified paths.
    # data - hash, array or string
    # paths - arrays of strings ["", ""], ["", ""]
    # returns a hash of result
    def find_all_by_paths(data, *paths)
      results = []

      paths.each do |path|
        result = self.find_by_path(data, path)
        result = result.compact.flatten if result.is_a?(Array)

        # Store data as a path-value pair.
        results << [path.join('/'), result] unless result.blank?
      end

      results.to_h
    end


    # Retrieves the value object of the specified path.
    # data - hash, array or string
    # path  - an array of strings ["", ""]
    # returns value if any datatype e.g., [], {}, "some value", { key: value, key: value }
    # ---
    # NOTE: This method does something similar to what Hash#dig does but
    # the difference is this method proceed recursively even if the data is an array.
    def find_by_path(data, path)
      # Ensure args are of proper data types.
      unless data.is_a?(String) || data.is_a?(Array) || data.is_a?(Hash)
        raise ArgumentError.new("data must be an string, array or hash")
      end

      raise ArgumentError.new("path must be an array") unless path.is_a?(Array)

      # Base case:
      return data if path.empty?

      # Pop a node from the path list.
      current_node, remaining_path = path[0], path[1..-1]

      # Continue the process.
      if current_node == ARRAY_NODE
        # Recurse on all the nodes in the array.
        data.map { |d| self.find_by_path(d, remaining_path) }
      elsif data.is_a?(Hash) && data[current_node]
        # If data is a hash, recurse on the remaining path.
        self.find_by_path(data[current_node], remaining_path)
      else
        data
      end
    end


    # Returns array of values.
    def deep_find_all_by_key(data, key)
      data.extend Hashie::Extensions::DeepFind
      data.deep_find_all(key)
    end


    # Returns array of key-value pairs(hashes).
    def deep_locate_all_by_key(data, key)
      data.extend Hashie::Extensions::DeepLocate
      results = data.deep_locate -> (k, v, object) { k == key && v.present? }
      results = results.uniq
    end


    def all_variants(string)
      [string.singularize, string.pluralize].map do |s|
        [s.titleize, s.camelize, s.underscore, s.tableize, s.humanize]
      end.flatten.uniq
    end
  end
end
