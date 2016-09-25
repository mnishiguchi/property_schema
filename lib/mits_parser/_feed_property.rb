=begin
- Stores as much info as possible about source feed.
- Provides conviersion method property_attributes, which extracts what we consider
to be usufut for Property model.
=end
class FeedProperty < ApplicationRecord
  strip_attributes
  include Notable

  belongs_to :mits_container
  belongs_to :property_container, optional: true

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

  # Values that users can pick from - picks a default if primary_#{attribute}_key is not set

  def name
    names[primary_name_key] || default_name
  end

  def default_name
    names.values.first
  end

  def email
    emails[primary_email_key] || default_email
  end

  def default_email
    emails.values.first
  end

  def url
    urls[primary_url_key] || default_url
  end

  def default_url
    urls.values.first
  end

  def phone
    phones[primary_phone_key] || default_phone
  end

  def default_phone
    phones.values.first
  end

  def description
    descriptions[primary_description_key] || default_description
  end

  def default_description
    descriptions.values.first
  end

  ## Values user can choose to ignore

  def photos_for_merge
    photo_urls - ignored_photo_urls
  end

  def utilities_for_merge
    utilities - ignored_utilities
  end

  def amenities_for_merge
    amenities - ignored_amenities
  end
end
