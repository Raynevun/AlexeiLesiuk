require 'net/http'
require 'uri'
require 'rexml/document'
require 'pry'

module Baecon

	BASE_URL = "https://beacon.nist.gov"

	class Record
		attr_accessor :version, :frequency, :time_stamp, :previous_output_value, :signature_value, :output_value, :seed_value, :status_code
		attr_reader :rawXml, :chars_entry
		def initialize xml
			@time_stamp =            xml.elements["record/timeStamp"].nil? ? nil : xml.elements["record/timeStamp"].text
			@version =               xml.elements["record/version"].nil? ? nil : xml.elements["record/version"].text
			@frequency =             xml.elements["record/frequency"].nil? ? nil : xml.elements["record/frequency"].text
			@seed_value =            xml.elements["record/seedValue"].nil? ? nil : xml.elements["record/seedValue"].text
			@previous_output_value = xml.elements["record/previousOutputValue"].nil? ? nil : xml.elements["record/previousOutputValue"].text
			@signature_value =       xml.elements["record/signatureValue"].nil? ? nil : xml.elements["record/signatureValue"].text
			@output_value =          xml.elements["record/outputValue"].nil? ? nil : xml.elements["record/outputValue"].text
			@status_code =           xml.elements["record/version"].nil? ? nil : xml.elements["record/version"].text


			if (!@output_value.nil?)
				@chars_entry = {}
				keys = @output_value.chars.uniq
				keys.each { |key|
					@chars_entry["#{key}"] = @output_value.count(key)
				}
			end
			#@chars_entry = @output_value.chars.uniq.map { |c| @chars_entry[c]=@output_value.count(c) }
		end
		def to_s
			str = ""
			@chars_entry.sort.each { |key, value| str += "#{key},#{value}\n"}
			return str
		end
	end	

	class Get 
		PATH = "/rest/record"

		def self.by_timestamp_now
			url = URI.parse(BASE_URL)
			time_now = Time.now
			time_stamp = time_now.to_i - time_now.sec
			url.path = "#{PATH}/#{time_stamp}"

			res = ApiRequest.new(url).result 
			Record.new(res)
		end
	end

	class ApiRequest < Struct.new(:url)
		def result
			response = Net::HTTP.get_response(url)
			#TODO: add verifications and make it in defencive style
			REXML::Document.new response.body
		end
	end

end