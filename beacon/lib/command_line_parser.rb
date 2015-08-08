#!/home/melkor/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class OptparseBeacon
  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.library = []
    options.inplace = false
    options.encoding = "utf8"
    options.transfer_type = :auto
    options.verbose = false
    options.user = ""

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      # Test argument.
      opts.on("-u", "--user USERNAME", String,
              "Search by USERNAME in login, full name and e-mail fields") do |username|
        options.user = username
      end

      # Mandatory argument.
      opts.on("-r", "--require LIBRARY",
              "Require the LIBRARY before executing your script") do |lib|
        options.library << lib
      end

      # Optional argument; multi-line description.
      opts.on("-i", "--inplace [EXTENSION]",
              "Edit ARGV files in place",
              "  (make backup if EXTENSION supplied)") do |ext|
        options.inplace = true
        options.extension = ext || ''
        options.extension.sub!(/\A\.?(?=.)/, ".")  # Ensure extension begins with dot.
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      # opts.on_tail("-v", "--version", "Show version") do
      #   puts ::Version.join('.')
      #   exit
      # end
    end

    opt_parser.parse!(args)
    options
  end  # parse()

end  # class OptparseExample


