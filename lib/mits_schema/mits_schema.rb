class MitsSchema

  def self.from_xml(xml)
    parsed_doc = Nokogiri::XML(xml)

    if has_files_nested_within_floorplan?(parsed_doc)
      MitsSchema::WithNestedFiles.new(parsed_doc)
    elsif has_linked_files?(parsed_doc)
      MitsSchema::WithLinkedFiles.new(parsed_doc)
    else
      MitsSchema::Else.new(parsed_doc)
    end
  end

  def self.has_files_nested_within_floorplan?(parsed_doc)
    !!parsed_doc.at_xpath("//Floorplan//File") ||
    !!parsed_doc.at_xpath("//Floorplan//Slideshow") ||
    !!parsed_doc.at_xpath("//Floorplan//PhotoSet")
  end

  def self.has_linked_files?(parsed_doc)
    !!parsed_doc.xpath("//Property/Floorplan")[0]&.at_xpath("@id") &&
    !!parsed_doc.xpath("//Property/File")[0]&.at_xpath("@id")
  end
end


# ---
# ---


class MitsSchema::WithNestedFiles
  def initialize(parsed_doc)

    puts "invoked: MitsSchema::WithNestedFiles"

  end
end

class MitsSchema::WithLinkedFiles
  def initialize(parsed_doc)

    puts "invoked: MitsSchema::WithLinkedFiles"

  end
end

class MitsSchema::Else
  def initialize(parsed_doc)

    puts "invoked: MitsSchema::Else"

  end
end
