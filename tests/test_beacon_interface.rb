#
require 'pp'
require 'test/unit'
require 'webmock/test_unit'
require_relative "../beacon/lib/beacon_interface.rb"

class TestBeaconInterface < Test::Unit::TestCase

  def test_beacon_record_initialization 
    golden_record_xml = File.read("tests/expected_xml/golden_record_by_timestamp.xml")
    record = Beacon::Record.new golden_record_xml
    assert_equal( record.time_stamp, "1439035020" )
    assert_equal( record.version, "Version 1.0" )
    assert_equal( record.seed_value, "SEED VALUE" )
    assert_equal( record.previous_output_value, "Previous Output Value" )
    assert_equal( record.signature_value, "Signature Value" )
    assert_equal( record.output_value, "ABBCCCDDDD" )
    assert_equal( record.status_code, "0" )
  end


  def test_beacon_hash_chars_entry_calculation
    assert_equal( nil, Beacon::Record.get_chars_entry(nil) )
    assert_equal( {}, Beacon::Record.get_chars_entry("") )
    assert_equal( {"1"=>1}, Beacon::Record.get_chars_entry("1") )
    assert_equal( {"A"=>1, "B"=>2, "C"=>3}, Beacon::Record.get_chars_entry("ABBCCC") )
  end

  def test_assert_chars_entry_string_composition
    golden_record_xml = File.read("tests/expected_xml/golden_record_by_timestamp.xml")
    expected_string = "A,1\nB,2\nC,3\nD,4\n"
    record = Beacon::Record.new golden_record_xml
    assert_equal( expected_string, record.to_s )
  end


  #this is just pisitive test, no any defence inside the API methods
  def test_baecon_api_request
    expected_body = File.read("tests/expected_xml/get_record_by_timestamp.xml")

    stub_request(:get, "https://beacon.nist.gov/rest/record/1439035020").
        with(:headers => {'Accept'=>'*/*', 
                          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
                          'Host'=>'beacon.nist.gov', 
                          'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => expected_body, :headers => {})
    

    record = Beacon::Get.by_timestamp "1439035020"   
    
    assert_equal( record.time_stamp, "1439035020" )
    assert_equal( record.version, "Version 1.0" )
    # And go on.. 
  end

  def test_beacon_api_request_exception_handling_404
    incorrect_time_stamp = "9999999999"
    expected_body        = "HTTP 404 Error: record not found for timevalue #{incorrect_time_stamp}"
    url                  = "https://beacon.nist.gov/rest/record/#{incorrect_time_stamp}"
    
    stub_request(:get, url).with(:headers => {'Accept'=>'*/*', 'Host'=>'beacon.nist.gov'}).
        to_return(:status => 404, :body => expected_body, :headers => {})    

    assert_raise do |error|
        record = Beacon::Get.by_timestamp "#{incorrect_time_stamp}"
    end
  end


  def test_beacon_api_request_exception_handling_400
    url = "https://beacon.nist.gov/rest/record/asdasdasd"
    stub_request(:get, url).with(:headers => {'Accept'=>'*/*', 'Host'=>'beacon.nist.gov'}).
        to_return(:status => 400, :body => "", :headers => {})    

    assert_raise do |error|
        record = Beacon::Get.by_timestamp "#{incorrect_time_stamp}"
    end
  end


  def test_beacon_api_request_exception_handling
    incorrect_time_stamp = "9999999999"
    expected_body = "HTTP 404 Error: record not found for timevalue #{incorrect_time_stamp}"
    stub_request(:get, "https://beacon.nist.gov/rest/record/#{incorrect_time_stamp}").
        with(:headers => {'Accept'=>'*/*', 'Host'=>'beacon.nist.gov'}).
        to_return(:status => 404, :body => expected_body, :headers => {})    

    assert_raise do |error|
        record = Beacon::Get.by_timestamp "#{incorrect_time_stamp}"
    end
  end


  def test_api_request 
    expected_body = File.read("tests/expected_xml/golden_record_by_timestamp.xml")

    stub_request(:get, "https://beacon.nist.gov/rest/record/1439035020").
        with(:headers => {'Accept'=>'*/*', 'Host'=>'beacon.nist.gov'}).
        to_return(:status => 200, :body => expected_body, :headers => {})    
        res = Beacon::ApiRequest.new( URI.parse("https://beacon.nist.gov/rest/record/1439035020") )
        assert_equal( expected_body, res.result )
  end

end