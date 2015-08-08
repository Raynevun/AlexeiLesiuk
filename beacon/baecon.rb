#!/home/melkor/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'pp'
require_relative "lib/command_line_parser"
require_relative "lib/baecon_interface"


case ARGV.count
    when 0
        record = Baecon::Get.by_timestamp_now
        puts record.to_s
        #pp record
    else
       options = OptparseBeacon.parse(ARGV)
       pp options
end