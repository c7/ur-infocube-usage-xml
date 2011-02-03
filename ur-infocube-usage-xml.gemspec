lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'version'

Gem::Specification.new do |s|
  s.name        = "ur-infocube-usage-xml"
  s.version     = InfocubeUsageXML::VERSION::STRING
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = "Generate Infocube usage XML from Wowza access log"
  s.description = "Calculates the number of stream events from a " +
                  "Wowza access log and generates an Infocube usage XML"
  s.email       = "peter.hellberg@athega.se"
  s.homepage    = "http://backstage.ur.se/infocube-usage-xml"
  s.authors     = ["Peter Hellberg"]

  s.executables = ['infocube_usage_xml']
  s.default_executable = 'infocube_usage_xml'

  s.has_rdoc          = false
  s.files             = Dir.glob("lib/**/*")

  s.add_dependency('thor', '>= 0.14.6')
  s.add_dependency('nokogiri', '>= 1.4.1')
  s.add_dependency('fastercsv', '>= 1.5.3')
end
