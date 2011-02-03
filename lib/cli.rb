$:.unshift(File.expand_path('..', __FILE__))

require 'rubygems'
require 'version'
require 'wowza_access_log_parser'
require 'thor'

module InfocubeUsageXML
  class CLI < Thor
    include Thor::Base
    include Thor::Actions

    DEBUG = false

    default_task :parse

    desc 'parse', "Generate a new Infocube Usage XML " +
                  "(--output-file=FILE_NAME to save output)"

    method_option :wowza_access_log,
                  :required => true,
                  :banner => '', :desc => 'Input file (CSV)'

    method_option :output_file,
                  :reqired => false,
                  :banner => '', :desc => 'Optional output file (XML)'

    method_option :usage_compiler,
                  :required => true, :aliases => ['-u'],
                  :banner => '', :desc => 'Usage compiler'

    method_option :contracting_party,
                  :required => true, :aliases => ['-c'],
                  :banner => '', :desc => 'Contracting party'

    method_option :educator_name,
                  :required => true, :aliases => ['-e'],
                  :banner => '', :desc => 'Educator name'

    method_option :date, :required => true, :aliases => ['-d'],
                  :banner => '', :desc => 'Format: yyyy-mm-dd'

    def parse
      user_alias = options[:alias]

      parser = WowzaAccessLogParser.new(options)

      if options[:output_file].nil?
        puts parser.to_xml
      else
        create_file(options[:output_file], :verbose => DEBUG) do
          parser.to_xml
        end
      end
    end

    desc :version, "The current version number (#{VERSION::STRING})"
    def version
      puts VERSION::STRING
    end
  end
end
