=begin
The MitsFormatter class provides us with a single location to
configure each fields of the Properties table. Its initializer
takes a feed data. We create subclasses of the Base class that
correspond to the Property model's column names and specify how
to determine the result for each field.
---
Usage:
  address = MitsFormatter::Address.format!(data)
=end

module MitsFormatter

  class Base
    attr_reader :result

    # Public API. Takes in an array of data for a given field.
    # Returns a processed data as result.
    def self.format!(data)
      formatter = new(data)
      formatter.result || {}
    end

    protected

      def initialize(data)
        raise "data must be array" unless data.is_a?(Array)
        @result = data  # The result is equal to data by default.
      end

      # Applies to @result the specified filters to format the data.
      # filters - an array of filter lambdas.
      # Usage:
      #   filter_root!(
      #     ->(k, v) { /n\/a/i =~ v ? [k, ""] : [k, v] },
      #     ->(k, v) { /address/i =~ k ? ["Address", v] : [k, v] },
      #   )
      def filter_root!(filters)
        return unless @result.is_a? Hash
        filters.each { |filter| @result = @result.map(&filter) }
        @result = Hash[@result]
      end

      def filter_child!(key, filters)
        return unless @result.is_a? Hash

        data_at_key = @result[key]
        return self unless data_at_key

        # puts "------Before------"
        # ap data_at_key

        filters.each { |filter| data_at_key = data_at_key.map(&filter) }
        @result[key] = Hash[data_at_key]

        # puts "------After------"
        # ap @result[key]
        # puts "------End Format------"
      end

      # TODO
      def format_recursively!(key, filters)
      end

      def replace_key(regex, new_key)
        ->(k, v) { regex =~ k ? [new_key, v] : [k, v] }
      end

      def replace_result(regex, new_result)
        ->(k, v) { regex =~ v ? [k, new_result] : [k, v] }
      end
  end


  # ===
  # Subclasses that correspond to the Properties table's column names.
  # ===


  class Address < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first

      # Replaces "N/A" with "".
      # Standardizes on the "Address" key for the street address.
      # Standardizes on the "County" key for the county.
      # Standardizes on the "Zip" key for the zipcode.
      filter_root! [
        replace_key(/address/i, "Address"),
        replace_key(/county/i, "County"),
        replace_key(/zip|postal/i, "Zip"),
        replace_result(/n\/a/i , "")
      ]
    end
  end

  class Amenities < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first

      filter_child! "Community", [
        replace_key(/Availab.*24.*/i, "AlwaysAvailable")
      ]

      filter_child! "Floorplan", [
        replace_key(/WD_Hookup/i, "WasherDryerHookup"),
        replace_result(/true|t|1/i, "true"),
        replace_result(/false|f|0/i, "false")
      ]
    end
  end

  class Description < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class Email < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class FeedUid < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class Floorplans < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data
    end
  end

  class Information < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class Latitude < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class LeaseLength < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      lease_length = data.first
      if lease_length.is_a?(String)
        @result = {
          "Min" => lease_length,
          "Max" => nil
        }
      elsif lease_length.is_a?(Hash) && lease_length["Min"]
        @result = lease_length
      else
        @result = {
          "Min" => nil,
          "Max" => nil
        }
      end
    end
  end

  class Longitude < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class Name < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class OfficeHours < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      json = data.to_json
      json.gsub!(/sunday/i, "Sunday")
      json.gsub!(/monday/i, "Monday")
      json.gsub!(/tuesday/i, "Sunday")
      json.gsub!(/wednesday/i, "Wednesday")
      json.gsub!(/thursday/i, "Thursday")
      json.gsub!(/friday/i, "Friday")
      json.gsub!(/saturday/i, "Saturday")
      @result = JSON.parse(json)
    end
  end

  class Parking < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data
    end
  end

  class PetPolicy < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data
    end
  end

  class Phone < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract phone number from data.
      phone_regex = /\A(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\z/
      @result = data.first
    end
  end

  class Photos < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Our format: an array of URL strings.
      url_regex = /(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/
      @result = data.map { |el| el.to_s.scan(url_regex) }.flatten
    end
  end

  class Promotions < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data
    end
  end

  class Url < MitsFormatter::Base
    def initialize(data)
      super(data)

      # Extract a result we want from the data.
      @result = data.first
    end
  end

  class Utilities < MitsFormatter::Base
    def initialize(data)
      super(data)

      # TODO: What data comes here?

      # Extract a result we want from the data.
      @result = data
    end
  end
end
