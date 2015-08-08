#!/home/melkor/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'pp'
require_relative "lib/command_line_parser"
require_relative "lib/beacon_interface"


case ARGV.count
    when 0
        record = Beacon::Get.by_timestamp( Beacon::TimeStamp.round_to_sec(Time.now) )
        puts record.to_s
    else
        options = OptparseBeacon.parse(ARGV)
        time_from = Beacon::TimeStamp.option_to_date_time(options.from)
        time_to = Beacon::TimeStamp.option_to_date_time(options.to)

        res = Beacon::Get.by_period( time_from, time_to )
        puts Beacon::Record.chars_entry_to_s res
end