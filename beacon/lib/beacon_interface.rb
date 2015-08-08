require 'net/http'
require 'uri'
require 'rexml/document'
require 'pry'

module Beacon

    BASE_URL = "https://beacon.nist.gov"

    class Record
        attr_accessor :version, :frequency, :time_stamp, :previous_output_value, :signature_value, :output_value, :seed_value, :status_code
        attr_reader :chars_entry
        def initialize source_xml
            xml = REXML::Document.new source_xml

            @time_stamp =            xml.elements["record/timeStamp"].nil? ? nil : xml.elements["record/timeStamp"].text
            @version =               xml.elements["record/version"].nil? ? nil : xml.elements["record/version"].text
            @frequency =             xml.elements["record/frequency"].nil? ? nil : xml.elements["record/frequency"].text
            @seed_value =            xml.elements["record/seedValue"].nil? ? nil : xml.elements["record/seedValue"].text
            @previous_output_value = xml.elements["record/previousOutputValue"].nil? ? nil : xml.elements["record/previousOutputValue"].text
            @signature_value =       xml.elements["record/signatureValue"].nil? ? nil : xml.elements["record/signatureValue"].text
            @output_value =          xml.elements["record/outputValue"].nil? ? nil : xml.elements["record/outputValue"].text
            @status_code =           xml.elements["record/statusCode"].nil? ? nil : xml.elements["record/statusCode"].text

            @chars_entry = self.class.get_chars_entry( @output_value )
        end

        def self.get_chars_entry str
            if (!str.nil?)
                chars_hash = {}
                keys = str.chars.uniq
                keys.each { |key|
                    chars_hash["#{key}"] = str.count(key)
                }
            end
            chars_hash
        end

        def self.chars_entry_to_s chars_entry_hash
            result = ""
            chars_entry_hash.sort.each { |key, value| result += "#{key},#{value}\n"}
            return result
        end

        def to_s
            self.class.chars_entry_to_s @chars_entry
        end
    end 

    class TimeStamp
        def self.round_to_sec
            time_now = Time.now
            time_stamp = time_now.to_i - time_now.sec
        end
    end

    class Get 
        PATH = "/rest/record"

        def self.by_timestamp time_stamp
            url = URI.parse(BASE_URL)
            url.path = "#{PATH}/#{time_stamp}"

            source_xml = ApiRequest.new(url).result 
            Record.new(source_xml)
        end
    end

    class ApiRequest < Struct.new(:url)
        def result
            response = Net::HTTP.get_response(url)
            #TODO: add verifications and make it in defencive style
            response.body
        end
    end

end