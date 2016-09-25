=begin
A feed parser that is used for parsing a feed xml into mits format.
It is used in Mits class.
=end

class MitsParser
  def self.dig_any(hash, default_value, *set_of_paths)
    set_of_paths.each do |paths|
      result = MitsParser.dig(hash, paths)
      result = result.compact.flatten if result.is_a?(Array)
      next if result.blank?
      return result
    end
    default_value
  end

  def self.dig_all(hash, *set_of_paths)
    {}.tap do |results|
      set_of_paths.each do |paths|
        result = MitsParser.dig(hash, paths)
        result = result.compact.flatten if result.is_a?(Array)
        next if result.blank?
        results[paths.join.underscore.to_sym] = result
      end
    end
  end

  # source - source data of any data type, typically hash, array, string
  # paths  - always an array of strings
  # returns value if any. Datatypes: Array, String, Hash.
  # e.g., [], {}, "some value", { key: value, key: value }
  def self.dig(source, paths)
    raise ArgumentError.new("paths must be an array") unless paths.is_a? Array

    # Base cases:
    return source if paths.empty?
    return {} unless source

    # Pop a path from the paths list.
    path            = paths.first
    remaining_paths = paths[1...paths.size]

    # "Array" is a special word we use to specify a node is an array.
    if path == "Array"
      # Apply this method to all the elements in the array.
      source.map do |h|
        MitsParser.dig(h, remaining_paths)
      end
    elsif source.is_a?(Hash) && (new_source = source[path])
      # If source is a hash, repeat recursively.
      MitsParser.dig(new_source, remaining_paths)
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

  class Amenities
    TRANSFORM_KEYS = {
      "Availability24Hours" => "AlwaysAvailable",
      "Available24Hours"    => "AlwaysAvailable",
      "WD_Hookup"           => "WasherDryerHookup"
    }

    TRANSFORM_VALUES = {
      ""      => nil,
      "f"     => false,
      "F"     => false,
      "false" => false,
      "False" => false,
      "0"     => false,
      "t"     => true,
      "T"     => true,
      "true"  => true,
      "True"  => true,
      "1"     => true,
    }

    def self.community(hash)
      fix(MitsParser.dig(hash, %w(Amenities Community)))
    end

    def self.floorplans(hash)
      fix(MitsParser.dig(hash, %w(Amenities Floorplan)))
    end

    def self.fix(hash)
      new_hash = {}.tap do |new_hash|
        hash.each do |key, value|
          transformed_key   = TRANSFORM_KEYS.key?(key) ? TRANSFORM_KEYS[key] : key
          transformed_key   = transformed_key.underscore.to_sym if transformed_key

          transformed_value =  TRANSFORM_VALUES.key?(value) ? TRANSFORM_VALUES[value] : value

          next if [transformed_key, transformed_value].any?(&:nil?)
          next if transformed_value.is_a?(Hash) && transformed_value.blank?
          next if transformed_value.is_a?(Array) && transformed_value.blank?

          new_hash[transformed_key] = transformed_value
        end
      end
      new_hash.select { |k,v| v }.keys
    end
  end

  class Utility
    TRANSFORM_KEYS = {
      "AirCon" => "AirConditioning"
    }

    TRANSFORM_VALUES = {
      ""      => nil,
      "f"     => false,
      "F"     => false,
      "false" => false,
      "False" => false,
      "0"     => false,
      "t"     => true,
      "T"     => true,
      "true"  => true,
      "True"  => true,
      "1"     => true,
    }

    def self.parse(hash)
      fix(MitsParser.dig(hash, %w(Utility)))
    end

    def self.fix(hash)
      new_hash = {}.tap do |new_hash|
        hash.each do |key, value|
          transformed_key   = TRANSFORM_KEYS.key?(key) ? TRANSFORM_KEYS[key] : key
          transformed_key   = transformed_key.underscore.to_sym if transformed_key
          transformed_value =  TRANSFORM_VALUES.key?(value) ? TRANSFORM_VALUES[value] : value

          next if [transformed_key, transformed_value].any?(&:nil?)
          next if transformed_value.is_a?(Hash) && transformed_value.blank?
          next if transformed_value.is_a?(Array) && transformed_value.blank?

          new_hash[transformed_key] = transformed_value
        end
      end
      new_hash.select { |k,v| v }.keys
    end
  end

  class Address
    def self.parse(hash)
      fix({
            address: MitsParser.dig_any(hash, "", %w(Identification Address Address1), %w(Identification Address ShippingAddress), %w(Identification Address MailingAddress), %w(PropertyID Address Address), %w(PropertyID Address Address1)),
            city:    MitsParser.dig_any(hash, "", %w(Identification Address City), %w(PropertyID Address City)),
            county:  MitsParser.dig_any(hash, "", %w(PropertyID Address CountyName)),
            zip:     MitsParser.dig_any(hash, "", %w(Identification Address Zip), %w(PropertyID Address Zip)),
            po_box:  MitsParser.dig_any(hash, "", %w(Identification Address PO_Box)),
            country: MitsParser.dig_any(hash, "USA", %w(Identification Address Country)),
            state:   MitsParser.dig_any(hash, "", %w(Identification Address State)),
          })
    end

    TRANSFORM_VALUES = {
      "N/A" => ""
    }

    def self.fix(hash)
      {}.tap do |new_hash|
        hash.each do |key, value|

          transformed_value = TRANSFORM_VALUES.key?(value) ? TRANSFORM_VALUES[value] : value

          next if [key, transformed_value].any?(&:nil?)
          next if transformed_value.is_a?(Hash) && transformed_value.blank?
          next if transformed_value.is_a?(Array) && transformed_value.blank?

          new_hash[key] = transformed_value
        end
      end
    end
  end

  class Photo
    def self.parse(hash)
      photo_hashes = MitsParser.dig(hash, %w(File Array)).compact.select { |file| file.is_a?(Hash) && (file.key?("FileType") || file.key?("Format")) }
      photo_hashes = photo_hashes.map do |photo_hash|
        fix(photo_hash)
      end
      floorplan_photos, photo_hashes = photo_hashes.partition { |file| file[:type] == "floorplan" }

      # Index them because that makes life easier
      floorplan_photo_hashes = {
        affiliate_id: {},
        name: {},
        id: {}
      }
      floorplan_photos.each do |floorplan_photo|
        [:affiliate_id, :name, :id].each do |key|
          next unless floorplan_photo[key]
          floorplan_photo_hashes[key][floorplan_photo[key]] = floorplan_photo[:src] || floorplan_photo[:source_url]
        end
      end
      community_photos = []

      photo_hashes.each do |photo_hash|
        community_photos << photo_hash[:src] if photo_hash
      end
      {
        floorplan_photos: floorplan_photo_hashes,
        community_photos: community_photos
      }
    end

    def self.floorplan_photos(hash)
      Photo.parse(hash)[:floorplan_photos]
    end

    def self.community_photos(hash)
      Photo.parse(hash)[:community_photos]
    end

    TRANSFORM_KEYS = {
      "Rank"        => nil,         # Drop Rank
      "Caption"     => nil,         # Drop Caption
      "AffiliateId" => "Id",        # Convert to standardized Id
      "Src"         => "SourceUrl"
    }
    TRANSFORM_VALUES = {
      "image/jpeg" => "jpg",
      "JPG"        => "jpg",
      "jpg"        => "jpg",
      "png"        => "png",
      "gif"        => "gif",
      "PNG"        => "png"
    }

    def self.fix(hash)
      {}.tap do |new_hash|
        hash.each do |key, value|
          transformed_key   = TRANSFORM_KEYS.key?(key) ? TRANSFORM_KEYS[key] : key
          transformed_key   = transformed_key.underscore.to_sym if transformed_key

          transformed_value =  TRANSFORM_VALUES.key?(value) ? TRANSFORM_VALUES[value] : value

          next if [transformed_key, transformed_value].any?(&:nil?)
          next if transformed_value.is_a?(Hash) && transformed_value.blank?
          next if transformed_value.is_a?(Array) && transformed_value.blank?

          new_hash[transformed_key] = transformed_value
        end
      end
    end
  end

  class Parking
    def self.parse(hash)
      parking_hash = MitsParser.dig(hash, %w(Information Parking))
      return {} unless parking_hash

      # We have some of the keys nested in an array - but the rest are not - Might want to make a method out of this if it becomes an issue
      parking_array = MitsParser.dig(parking_hash, %w(Array)).map { |parking_array_hash| Parking.fix(parking_array_hash) }.compact
      parking_array.tap do |parking_arrays|
        other_parking_array_hashes = MitsParser.dig_all(parking_hash, * %w(Assigned AssignedFee Comment SpaceFee Spaces).map { |a| Array(a) })
        parking_arrays << Parking.fix(other_parking_array_hashes) if other_parking_array_hashes && other_parking_array_hashes != {}
      end
    end

    TRANSFORM_VALUES = {
      "free" => 0,
      "true" => true,
      "false" => false
    }

    def self.fix(hash)
      {}.tap do |new_hash|
        hash.each do |key, value|
          key = key.underscore.to_sym if key.is_a?(String)

          transformed_value =  TRANSFORM_VALUES.key?(value) ? TRANSFORM_VALUES[value] : value

          next if [key, transformed_value].any?(&:nil?)
          next if transformed_value.is_a?(Hash) && transformed_value.empty?

          new_hash[key] = transformed_value
        end
      end
    end
  end

  class OfficeHours

    def self.parse_date(string_time)
      return string_time if ["Closed", "By Appointment Only"].include?(string_time)
      Time.parse(string_time).strftime("%R")
    end

    TRANSFORM_DAYS = {
      "su" => :sunday,
      "m"  => :monday,
      "t"  => :tuesday,
      "w"  => :wednesday,
      "th" => :thursday,
      "f"  => :friday,
      "sa" => :saturday,
      "sunday"    => :sunday,
      "monday"    => :monday,
      "tuesday"   => :tuesday,
      "wednesday" => :wednesday,
      "thursday"  => :thursday,
      "friday"    => :friday,
      "saturday"  => :saturday
    }



    def self.parse(hash)
      office_hours_by_day = MitsParser.dig(hash, %w(Information OfficeHour))
      {}.tap do |office_hour_hash|
        office_hours_by_day.each do |office_hour_day|
          day = office_hour_day["Day"].downcase
        day = TRANSFORM_DAYS[day] if TRANSFORM_DAYS.key?(day)
          office_hour_hash[day] = {
            open:  OfficeHours.parse_date(office_hour_day["OpenTime"]),
            close: OfficeHours.parse_date(office_hour_day["CloseTime"])
          }
        end
      end
    end

  end

  class PetPolicy
    TRANSFORM_KEYS = {
      "Availability24Hours" => "AlwaysAvailable",
      "Available24Hours"    => "AlwaysAvailable",
      "WD_Hookup"           => "WasherDryerHookup"
    }

    TRANSFORM_VALUES = {
      ""      => nil,
      "false" => false,
      "False" => false,
      "true"  => true,
      "True"  => true,
    }

    def self.parse(hash)
      # fix(MitsParser.dig(hash, %w(Policy Pet)))
      policy_pet_hash = MitsParser.dig(hash, %w(Policy Pet))

      # We have some of the keys nested in an array - but the rest are not - Might want to make a method out of this if it becomes an issue
      policy_pet_array = MitsParser.dig(policy_pet_hash, %w(Array)).map { |policy_pet_array_hash| PetPolicy.fix(policy_pet_array_hash) }.compact
      policy_pet_array.tap do |policy_pet_arrays|
        other_policy_pet_array_hashes = MitsParser.dig_all(policy_pet_hash, * %w(Comment Deposit Fee MaxCount PetCare Rent Restrictions Weight).map { |a| Array(a) })
        policy_pet_arrays << other_policy_pet_array_hashes if other_policy_pet_array_hashes && other_policy_pet_array_hashes != {}
      end
      {
        general:   MitsParser.dig(hash, %w(Policy General)),
        specifics: policy_pet_hash
      }
    end

    def self.fix(hash)
      return if hash.is_a?(Array)
      {}.tap do |new_hash|
        hash.each do |key, value|
          transformed_key   = TRANSFORM_KEYS.key?(key) ? TRANSFORM_KEYS[key] : key
          transformed_key   = transformed_key.underscore.to_sym if transformed_key

          transformed_value =  TRANSFORM_VALUES.key?(value) ? TRANSFORM_VALUES[value] : value

          next if [transformed_key, transformed_value].any?(&:nil?)
          next if transformed_value.is_a?(Hash) && transformed_value.empty?

          new_hash[transformed_key] = transformed_value
        end
      end
    end
  end

  class Floorplan

    def self.parse(hash, floorplan_photos)
      hashes = MitsParser.dig(hash, %w(Floorplan Array))
      floorplan_hashes = hashes.map do |floorplan_hash|
        case floorplan_hash
        when Hash
          bathroom_count = count_of_rooms(floorplan_hash, BEDROOM_KEY ) + floorplan_hash.fetch("Bathrooms", 0).to_i
          bedroom_count  = count_of_rooms(floorplan_hash, BATHROOM_KEY) + floorplan_hash.fetch("Bedrooms", 0).to_i

          name         = floorplan_hash.fetch("Name", "")
          floorplan_id = floorplan_hash.slice("id", "Id").values.detect(&:itself)
          affiliate_id = floorplan_hash.fetch("AffiliateID", "")
          {
            ## Feed Data stuff
            raw_hash:                  floorplan_hash,
            unique_feed_identifiers:   MitsParser.dig_all(floorplan_hash, %w(id), %w(Id), %w(Identification IDValue), %w(Identification IDType)),

            ## Has One to Has One
            name:                      name,

            # Integers
            deposit:                   safe_integer(Floorplan.deposit(floorplan_hash), -1),

            # These integers should be ignored if they are zero - this concern might have to be worked out a bit better
            unit_count:                safe_integer(MitsParser.dig_any(floorplan_hash, 0, %w(DisplayedUnitsAvailable), %w(UnitCount))),
            units_available_today:     safe_integer(floorplan_hash["UnitsAvailable"]),
            units_available_one_month: safe_integer(floorplan_hash["UnitsAvailable30Days"]),
            units_available_two_month: safe_integer(floorplan_hash["UnitsAvailable60Days"]),
            total_room_count:          safe_integer(floorplan_hash["TotalRoomCount"]),
            bathroom_count:            safe_integer(bathroom_count),
            bedroom_count:             safe_integer(bedroom_count),

            square_feet_min:           safe_integer(Floorplan.square_feet_min(floorplan_hash)),
            square_feet_max:           safe_integer(Floorplan.square_feet_max(floorplan_hash)),

            rent_max:                  safe_integer(Floorplan.rent_max(floorplan_hash)),
            rent_min:                  safe_integer(Floorplan.rent_min(floorplan_hash)),

            ## Has Many to Has One
            descriptions:              MitsParser.dig_all(floorplan_hash,
                                                          %w(Comment),
                                                          %w(Concession Description),
                                                          %w(Amenities General)),
            ## Has Many to Has Many
            amenities:                 Amenities.floorplans(floorplan_hash),
            photo_urls:                Floorplan.determine_photos(floorplan_photos, floorplan_hash, name, floorplan_id, affiliate_id),
          }
        when Array
          # TODO
          # Hahaha... Let's worry about this later
          {}
        end
      end
      # Could add admin notification when one is rejected
      floorplan_hashes.select { |floorplan| (floorplan[:unique_feed_identifiers]&.size || 0) > 0 }
    end

    def self.safe_integer(value, cutoff = 0)
      return if value.nil?
      value = value.to_i if value.is_a?(String)
      (value <= cutoff) ? nil : value
    end

    def self.determine_photos(floorplan_photos, floorplan_hash, name, id, affiliate_id)
      [].tap do |photo_urls|
        photo_urls << floorplan_photos[:affiliate_id][affiliate_id] if floorplan_photos[:affiliate_id][affiliate_id] && affiliate_id
        photo_urls << floorplan_photos[:name][name]                 if floorplan_photos[:name][name]                 && name
        photo_urls << floorplan_photos[:id][id]                     if floorplan_photos[:id][id]                     && id
        photo_urls << floorplan_hash[:image_url]                    if floorplan_hash[:image_url]
      end
    end

    BEDROOM_KEY    = MitsParser.brute_force_keys("Bedroom")
    BATHROOM_KEY   = MitsParser.brute_force_keys("Bathroom")
    ROOM_TYPE_KEYS = ["Comment", "RoomType", "type"].map { |key| MitsParser.brute_force_keys(key) }.flatten
    def self.count_of_rooms(floorplan_hash, room_types)

      (floorplan_hash.fetch("Room", []).map do |floorplan_hash|
         case floorplan_hash
         when Array # Evil
           (floorplan_hash.last || 0).to_i
         when Hash
           if (room_types & floorplan_hash.slice(ROOM_TYPE_KEYS).values).any?
             floorplan_hash.slice("Count", "Size").values.map(&:to_i).sum
           else
             0
           end
         end
       end).sum
    end

    def self.deposit(floorplan_hash)
      case deposit = MitsParser.dig_any(floorplan_hash, 0, %w(Deposit Amount))
      when Hash
        deposit["ValueRange"]["Exact"].to_i
      when String
        deposit.to_i
      end
    end

    def self.square_feet_max(floorplan_hash)
      MitsParser.dig_all(floorplan_hash,
                         %w(SquareFeet max),  %w(SquareFeet Max),
                        ).values.map(&:to_i).max
    end

    def self.square_feet_min(floorplan_hash)
      MitsParser.dig_all(floorplan_hash,
                         %w(SquareFeet min),  %w(SquareFeet Min),
                        ).values.map(&:to_i).min
    end

    def self.rent_max(floorplan_hash)
      MitsParser.dig_all(floorplan_hash,
                         %w(MarketRent max),    %w(MarketRent Max),
                         %w(EffectiveRent max), %w(EffectiveRent Max)
                        ).values.map(&:to_i).max
    end

    def self.rent_min(floorplan_hash)
      MitsParser.dig_all(floorplan_hash,
                         %w(MarketRent min),    %w(MarketRent Min),
                         %w(EffectiveRent min), %w(EffectiveRent Min)
                        ).values.map(&:to_i).min
    end

  end


  class PropertyParser
    def self.parse(hash)
      photos = Photo.parse(hash)
      latitude  = MitsParser.dig_any(hash, "0", %w(Identification Latitude),  %w(ILS_Identification Latitude),  %w(PropertyID Identification Latitude)).to_f
      longitude = MitsParser.dig_any(hash, "0", %w(Identification Longitude),  %w(ILS_Identification Longitude),  %w(PropertyID Identification Longitude)).to_f

      {
        raw_hash:                hash.reject { |k,v| k == :floorplan },
        floorplans:              Floorplan.parse(hash, photos[:floorplan_photos]),
        unique_feed_identifiers: MitsParser.dig_all(hash, %w(id), %w(PropertyID Identification PrimaryID), %w(Identification PrimaryID), %w(Identification SecondaryID), %w(Identification IDValue)),

        longitude:         longitude,
        latitude:          latitude,

        names:             MitsParser.dig_all(hash, %w(Identification MarketingName), %w(PropertyID Identification MarketingName), %w(PropertyID MarketingName), %w(Identification MSA_Name), %w(Identification MSA_Number), %w(Identification OwnerLegalName)),
        urls:              MitsParser.dig_all(hash, %w(Identification Website), %w(Identification WebSite), %w(Identification General_ID ID), %w(Information DirectionsURL), %w(Information FacebookURL), %w(Information ListingImageURL), %w(Information PropertyAvailabilityURL), %w(Information VideoURL), %w(PropertyID Identification BozzutoURL), %w(PropertyID Identification WebSite), %w(PropertyID WebSite), %w(Payment CheckPayable), %w(Floorplan Amenities General)),
        emails:            MitsParser.dig_all(hash, %w(PropertyID Address Lead2LeaseEmail),  %w(PropertyID Address Email), %w(Identification Email), %w(OnSiteContact Email)),
        phones:            MitsParser.dig_all(hash, %w(Identification Phone Number), %w(Identification Phone Array), %w(Identification Fax Number), %w(PropertyID Phone PhoneNumber), %w(OnSiteContact Phone Number)),
        descriptions:      MitsParser.dig_all(hash, %w(Information LongDescription), %w(Information NeighborhoodText), %w(Information OverviewBullet1), %w(Information OverviewBullet2), %w(Information OverviewBullet3), %w(Information OverviewText), %w(Information OverviewTextStripped), %w(Information ShortDescription)),

        information:       MitsParser.dig_all(hash, %w(Information YearBuilt), %w(Information YearRemodeled), %w(Identification TwitterHandle), %w(Identification IDValue), %w(Information NumberOfAcres), %w(Information LeaseLength), %w(Information BuildingCount), %w(Information UnitCount)),

        office_hours:      OfficeHours.parse(hash),
        photo_urls:        photos[:community_photos],
        pet_policy:        PetPolicy.parse(hash),

        # Might be able to do searches in here similar to the lease length operation
        promotional_info:  MitsParser.dig_any(hash, "", %w(Promotional)),
        amenities:         Amenities.community(hash),
        utilities:         Utility.parse(hash),
        parking:           Parking.parse(hash),
      }.merge(Address.parse(hash)).merge(lease_length(hash))
    end

    def self.lease_length(hash)
      lease_length = MitsParser.dig(hash, %w(Information LeaseLength))
      return { lease_length_min: nil, lease_length_max: nil } if ["", nil, [], {}].include?(lease_length)

      lease_lengths = lease_length.scan(/\d+/).map(&:to_i)
      return { lease_length_min: nil,               lease_length_max: nil               } if lease_lengths.empty?
      return { lease_length_min: lease_lengths.min, lease_length_max: nil               } if lease_lengths.size == 1
      return { lease_length_min: lease_lengths.min, lease_length_max: lease_lengths.max }
    end
  end

  def self.parse_properties(properties_json)
    (properties_json["Property"] || []).map do |property|
      PropertyParser.parse(property)
    end
  end
end
