require "minitest/reporters"
Minitest::Reporters.use!

require 'awesome_print'
require 'pry'
require 'test_helper'
require 'support/active_support'
require 'support/webmock'

# The path to the 'fixture/files' directory
FILE_DIR = "#{Dir.pwd}/test/fixtures/files"

def valid_json?(json)
  begin
    JSON.parse(json)
    return true
  rescue Exception => e
    return false
  end
end
