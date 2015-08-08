require 'net/http'
require 'uri'
require 'rexml/document'
require 'pry'
require 'active_support/all'

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

        def self.sum hash1, hash2
            hash1.merge(hash2){|key, oldval, newval| newval + oldval}
        end
    end 

    class TimeStamp
        def self.round_to_sec time
            time_stamp = time.to_i - time.sec
        end

        def self.get_period t_from, t_to
            time_stamp_from = self.round_to_sec( t_from )
            time_stamp_to = self.round_to_sec( t_to )

            time_stamp = time_stamp_from
            period = []
            while time_stamp < time_stamp_to  do
               period.push(time_stamp)
               time_stamp += 60
            end
            period
        end

        def self.option_to_date_time option
            month_match = /\b(\d+)\b\s+month[s]*\b/.match option
            days_match = /\b(\d+)\b\s+day[s]*\b/.match option
            hours_match = /\b(\d+)\b\s+hour[s]*\b/.match option

            # if !(strip.end_with? "ago") then
            # end

            date_time = DateTime.now
            date_time -= month_match[1].to_i.months if !month_match.nil?
            date_time -= days_match[1].to_i.days  if !days_match.nil?
            date_time -= hours_match[1].to_i.hours if !hours_match.nil?
            
            date_time
        end
    end

    class Get 
        PATH = "/rest/record"

        def self.by_time time
            time_stamp = TimeStamp.round_to_sec(time)
            url = URI.parse(BASE_URL)
            url.path = "#{PATH}/#{time_stamp}"

            source_xml = ApiRequest.new(url).result 
            Record.new(source_xml)
        end

        def self.by_timestamp time_stamp
            url = URI.parse(BASE_URL)
            url.path = "#{PATH}/#{time_stamp}"

            source_xml = ApiRequest.new(url).result 
            Record.new(source_xml)
        end

        def self.by_period time_from, time_to
            result_chars_entry_hash = {}
            period = TimeStamp.get_period( time_from, time_to )

            period.each { |element|
                record = self.by_timestamp element
                result_chars_entry_hash = Record.sum(result_chars_entry_hash, record.chars_entry)
            }

            result_chars_entry_hash
        end
    end

    class ApiRequest < Struct.new(:url)
        def result
            #TODO: make normal exception handling
            response = Net::HTTP.get_response(url)
            if response.header.code != "200" then
                response.error!
            end
            response.body
        end
    end

end