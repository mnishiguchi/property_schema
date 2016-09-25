=begin
Represents a raw Mits feed that is imported from its registered feed url.
Usage:
1. Create/find an instance specifying a source url.
   e.g., mits_object = Mits.where(source_url: url).first_or_create()
2. Import a feed xml from the  source url.
   e.g., mits_object.import_xml
=end

class Mits

  # Imports a feed xml data from the registered source url and saves it
  # to database. Returns true if the import and save are successful,
  # false if the import is unsuccessful.
  def import_xml
    # ...
    convert_feed_to_feed_models
    # ...
  end

  def convert_feed_to_feed_models
    MitsParser.parse_properties(json_hash).each do |property_hash|
      floorplan_hashes = property_hash.delete(:floorplans).reject { |value| value == {} }
      # ...
    end
  end

  def create_feed_floorplans(mits_container, floorplan_hash)
    unique_floorplan_feed_identifier = [
      mits_container.unique_feed_identifier,
      floorplan_hash.delete(:unique_feed_identifiers).map { |k,v| "#{k}:#{v}" }.join
    ].join("-")

    FeedFloorplan.find_and_update_or_create(
      find_by: {
        mits_container_id:      mits_container.id,
        unique_feed_identifier: unique_floorplan_feed_identifier
      },
      update_with: floorplan_hash
    )
  end
end
