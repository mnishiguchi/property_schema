require_relative "./mits_formatter.rb"

=begin
A MitsParser object restructures a given piece of mits data into our
predetermined schema with assistance of the classes MitsQuery and  MitsFormatter.
---
Usage:
  formatted_mits = MitsParser.new(mits_data).parse
  #==> Formatted array of hashes.
=end

class MitsParser

  def initialize(mits_data)
    unless mits_data.is_a?(Array) || mits_data.is_a?(Hash)
      raise "data must be array or hash"
    end

    # Store the passed-in mits data.
    @data = mits_data

    # Create a MitsQuery representation of all the properties.
    @mits_query = MitsQuery::Properties.from(@data)
  end

  def parse
    @parsed ||= @mits_query.map { |property| format_property!(property) }
  end

  private

    # Takes a MitsQuery::Property object that represents a SINGLE property.
    def format_property!(mits_query)
      unless mits_query.is_a?(MitsQuery::Property)
        raise ArgumentError.new("mits_query must be a MitsQuery::Property")
      end

      # Step 1: Format things
      address      = MitsFormatter::Address.format!(mits_query.address)
      amenities    = MitsFormatter::Amenities.format!(mits_query.amenities)
      email        = MitsFormatter::Email.format!(mits_query.email)
      description  = MitsFormatter::FeedUid.format!(mits_query.description)
      feed_uid     = MitsFormatter::FeedUid.format!(mits_query.feed_uid)
      floorplans   = MitsFormatter::Floorplans.format!(mits_query.floorplans)
      information  = MitsFormatter::Information.format!(mits_query.information)
      name         = MitsFormatter::Name.format!(mits_query.name)
      latitude     = MitsFormatter::Latitude.format!(mits_query.latitude)
      lease_length = MitsFormatter::LeaseLength.format!(mits_query.lease_length)
      longitude    = MitsFormatter::Longitude.format!(mits_query.longitude)
      office_hours = MitsFormatter::OfficeHours.format!(mits_query.office_hours)
      parking      = MitsFormatter::Parking.format!(mits_query.parking)
      phone        = MitsFormatter::Phone.format!(mits_query.phone)
      photos       = MitsFormatter::Photos.format!(mits_query.photos)
      pet_policy   = MitsFormatter::PetPolicy.format!(mits_query.pet_policy)
      promotions   = MitsFormatter::Promotions.format!(mits_query.promotions)
      url          = MitsFormatter::Url.format!(mits_query.url)
      utilities    = MitsFormatter::Utilities.format!(mits_query.utilities)


      # Step 2: Create a hash in our desired format.
      {
        :raw_hash     => @data,

        ## Has One to Has One
        # Feed Attributes
        :name         => name,
        :email        => email,
        :url          => url,
        :phone        => phone,
        :description  => description,

        # :floorplans   => floorplans,

        :latitude     => latitude,
        :longitude    => longitude,
        :address      => address["Address"],
        :city         => address["City"],
        :po_box       => address["PO_Box"],
        :county       => address["County"],
        :state        => address["State"],
        :zip          => address["Zip"],
        :country      => address["Country"],

        :lease_length_min => lease_length["Min"],
        :lease_length_max => lease_length["Max"],

        ## Has Many to Has Many
        # Selectively Ignored Attributes
        :amenities    => amenities,
        :photos       => photos,
        :utilities    => utilities,
      }
    end
end

=begin
class FeedProperty < ApplicationRecord

  ...

  def property_attributes
    {
      ## Has Many to Has One
      # Mapped Attributes
      name:        name,
      email:       email,
      url:         url,
      phone:       phone,
      description: description,

      ## Has One to Has One
      # Feed Attributes
      longitude:        longitude,
      latitude:         latitude,
      address:          address,
      city:             city,
      po_box:           po_box,
      county:           county,
      zip:              zip,
      state:            state,
      country:          country,
      lease_length_min: lease_length_min,
      lease_length_max: lease_length_max,

      ## Has Many to Has Many
      # Selectively Ignored Attributes
      photo_urls:     photos_for_merge,
      amenities:   amenities_for_merge,
      utilities:   utilities_for_merge
    }.select { |key, value| [:id].exclude?(key) && [nil].exclude?(value) }
  end

=end
