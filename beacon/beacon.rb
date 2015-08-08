#!/home/melkor/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'pp'
require_relative "lib/command_line_parser"
require_relative "lib/beacon_interface"


case ARGV.count
    when 0
        record = Beacon::Get.by_timestamp( Beacon::TimeStamp.round_to_sec )
        puts record.to_s
        #pp record
    else
       options = OptparseBeacon.parse(ARGV)
       pp options
end