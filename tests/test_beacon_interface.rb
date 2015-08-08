#
require 'pp'
require 'test/unit'
require 'webmock/test_unit'
require_relative "../beacon/lib/beacon_interface.rb"

class TestBeaconInterface < Test::Unit::TestCase

  def test_beacon_record_initialization
    golden_record_xml = File.read("tests/expected_xml/get_record_by_timestamp.xml")
    record = Beacon::Record.new golden_record_xml
    assert_equal( record.time_stamp, "1439035020" )
    assert_equal( record.version, "Version 1.0" )
    assert_equal( record.seed_value, "CAE43C74B4CC25994FD6285FAA9F667E4CFA8F7AA1BF1289F728D925A6A63B00162D34727C0FF6297540D466D9F0749BB496A03D398ECCE08CE807B2A869E085" )
    assert_equal( record.previous_output_value, "5265082175EB11A902B71B25D234B419BC5FD9C8913457DC7B9F89E4531F4F5B9F2614C7428DA1F58E22E7DF4FAED362E132C415CC85D97B9D975AC01AFD9EFA" )
    assert_equal( record.signature_value, "0BABA944A460FFBC1C138B6CE182580A9211405564CB78B88640CA8A2FE561A7953FAF651B59C3D34EAED20E4E621E0A24351664274C68A0B7A634C65AB5727921EBD3E20806D7BFC5B007DED0A7ABBCFE2DE1CF9CA18D962F8E463ABFC59492DC0D5AF3718E4E4AECABF01A1691CFF559EB24DD327DCE5BC83210E2DBD08CC0601A0ADE174BDF4E1EF670A5CE3BAFB0564E4BCD49DF0AAA721A2CB9485D45D791AE281C3AC670B0621BD5A91447CF9CB797E522DE9F406059A95586A557139D07948A0A251F4AF547A36A21BDAD3728FB0139A6CFA10E54B5A099A7D744BA190F152275A873E8AAD408F2ABA98A4780BED752806E083DFA2A60CFD959CEC29E" )
    assert_equal( record.output_value, "A27C5CADC6E822736C9E6F0FF5A0DCF0903ABCF11CFE70D0DCD24E089983A5D2815FF71733DF8FBE5F010C57A576A7B730A5F4F2874819738E258E63FA4CAF8E" )
    assert_equal( record.status_code, "0" )
  end


  def test_beacon_hash_chars_entry_calculation
    assert_equal( nil, Beacon::Record.get_chars_entry(nil) )
    assert_equal( {}, Beacon::Record.get_chars_entry("") )
    assert_equal( {"1"=>1}, Beacon::Record.get_chars_entry("1") )
    assert_equal( {"A"=>1, "B"=>2, "C"=>3}, Beacon::Record.get_chars_entry("ABBCCC") )
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

end