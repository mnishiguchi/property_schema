require "active_support/all"
require "awesome_print"
require "hashie"
require "pry"

class Hash
  include Hashie::Extensions::DeepFind
  include Hashie::Extensions::DeepLocate
end

class String
  def all_variants
    [self.singularize, self.pluralize].map do |r|
      [r.titleize, r.camelize, r.underscore, r.tableize, r.humanize]
    end.flatten.uniq
  end
end

# Adopted from Rails
# http://apidock.com/rails/Hash/from_xml/class
def from_xml(xml, disallowed_types = nil)
  ActiveSupport::XMLConverter.new(xml, disallowed_types).to_h
end
