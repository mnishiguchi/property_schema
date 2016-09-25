require_relative "../lib/mits_parser/mits_query_finders.rb"
require_relative "test_helper.rb"

=begin
How to run this test: bundle exec guard
=end

describe MitsQueryFinders do

  let(:ash_property_data) do
    ash_path = File.join(FILE_DIR, "ash.xml")
    ash_xml = File.read(ash_path)
    Hash.from_xml(ash_xml)["PhysicalProperty"]
  end

  let(:boz_property_data) do
    boz_path = File.join(FILE_DIR, "boz.xml")
    boz_xml = File.read(boz_path)
    Hash.from_xml(boz_xml)["PhysicalProperty"]
  end

  class FakeKlass
    include MitsQueryFinders
  end


  # ===
  # ===


  describe ".find_by_path(data, path)" do

    it "Property/Array/Information/FacebookURL" do

      path     = ["Property", "Array", "Information", "FacebookURL"]
      expected = ["http://www.facebook.com/LakesideVA", "http://www.facebook.com/metropointeapts"]

      assert_equal(expected, FakeKlass.find_by_path(boz_property_data, path))
    end

    describe "data" do
      describe "when data is nil" do
        subject { FakeKlass.find_by_path(nil, ["Property"]) }

        it "raises an exception" do
          assert_raises(Exception)
        end
      end

      describe "when passed in as a generic object" do
        subject { FakeKlass.find_by_path(Object.new, ["Property"]) }

        it "raises an exception" do
          assert_raises(Exception)
        end
      end

      describe "when passed in as a string" do
        subject { FakeKlass.find_by_path("hello", ["Property"]) }

        it "returns the unprocessed data" do
          assert_equal("hello", subject)
        end
      end
    end

    describe "path" do

      describe "when passed in as empty path" do
        subject { FakeKlass.find_by_path(boz_property_data, []) }

        it "returns the unprocessed data" do
          assert_equal(boz_property_data, subject)
        end
      end
    end
  end


  # ===
  # ===


  describe ".find_all_by_paths(data, paths)" do

    it "returns correct result as a hash" do
      result_hash = FakeKlass.find_all_by_paths(boz_property_data,
      ["Property", "Array", "Information", "FacebookURL"]
      )
      expected = {
        "Property/Array/Information/FacebookURL" => ["http://www.facebook.com/LakesideVA", "http://www.facebook.com/metropointeapts"]
      }

      assert_equal(expected, result_hash)
    end
  end

  describe ".deep_locate_all_by_key(data, key)" do
    it "returns all the values as an array" do
      result_array = FakeKlass.deep_locate_all_by_key(boz_property_data, "OpenTime")
      assert result_array.include?({
        "OpenTime"  => "12:00 PM",
        "CloseTime" => "5:00 PM",
        "Day"       => "Sunday"
      })
    end
  end

  describe ".deep_find_all_by_key(data, key)" do
    it "returns all the values that were found as an array" do
      result_hash = FakeKlass.deep_find_all_by_key(boz_property_data, "Address")
      expected = [
        {
          "Address1"=>"6221 Summer Pond Drive",
          "City"=>"Centreville",
          "State"=>"VA",
          "PostalCode"=>"20121",
          "CountyName"=>"Fairfax",
          "Lead2LeaseEmail"=>"lakesideboz@lead2lease.com"
        },
        {
          "Address1"=>"11175 Georgia Avenue",
          "City"=>"Wheaton",
          "State"=>"MD",
          "PostalCode"=>"20902",
          "CountyName"=>"Montgomery",
          "Lead2LeaseEmail"=>"bmcmetropointe@lead2lease.com"
        }]
      assert_equal(expected, result_hash)
    end
  end

end
