#!/home/melkor/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'

class OptparseBeacon
  def self.parse(args)
    options = OpenStruct.new
    options.from = ""
    options.to = ""
    options.time_stamp

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: beacon.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      # Test argument.
      opts.on("-f", "--from FROM_DATE", String,
              "Acceptable format is 'MM month[s] DD day[s] SS second[s]") do |from_date|
        options.from = from_date
      end

      opts.on("-t", "--to TO_DATE", String,
              "Acceptable format is 'MM month[s] DD day[s] SS second[s]") do |to_date|
        options.to = to_date
      end

      opts.on("-s", "--time-stamp TIMESTAMP", String,
              "Acceptable format is UNIX POSIX format (number of seconds since midnight UTC, January 1, 1970") do |time_stamp|
        options.time_stamp = time_stamp
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end  # parse()
end  


