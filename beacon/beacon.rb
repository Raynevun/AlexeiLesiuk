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
        #minimum time is 1378395540

        #I know that it possible to make nice verification somewhere in classes
        if ( time_from.to_i < 1378395540 || time_to.to_i < 1378395540 ) then
            puts "Please note that Beacon service started only at Thu, 05 Sep 2013 15:39:00 GMT"
            puts "please use bigger value"
        else
            if time_to.nil? then 
                time_to = DateTime.now
            end
            if time_from.nil? then 
                time_from = DateTime.parse("Thu, 05 Sep 2013 15:39:00 GMT")
            end
            res = Beacon::Get.by_period( time_from, time_to )
            puts Beacon::Record.chars_entry_to_s res
        end
    
end