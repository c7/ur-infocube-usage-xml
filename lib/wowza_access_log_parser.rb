require 'nokogiri'
require 'faster_csv'

module InfocubeUsageXML
  class WowzaAccessLogParser
    def initialize(options)
      @usage_compiler    = options[:usage_compiler]
      @contracting_party = options[:contracting_party]
      @educator_name     = options[:educator_name]
      @products          = {}

      @wowza_access_log  = options[:wowza_access_log]
      @period_start      = "#{options[:date]}T00:00:00+01:00"
      @period_end        = "#{options[:date]}T23:59:59+01:00"
    end

    def to_xml
      order_id_pattern = /(?:ext|se)\/\d\d\d000-\d\d\d999\/((\d{6})-\d{1,2})/
      ignored_ips = ['213.115.95.132', '85.229.242.181']

      if File.exist? @wowza_access_log
        IO.foreach(@wowza_access_log) do |li|
          if li[24,7] == 'destroy'
            cols = FasterCSV.parse(li, :col_sep => "\t")[0]

            if cols[26].to_i > 0 && !ignored_ips.include?(cols[16])
              matches, order_id, ur_product_id = *cols[27].match(order_id_pattern)

              if !ur_product_id.nil?
                @products[ur_product_id] ||= {}
                @products[ur_product_id][order_id] ||= 0
                @products[ur_product_id][order_id] += 1
              end
            end
          end
        end

        builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
          xml.usage('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                    'xmlns' => 'http://www.ur.se/infocube/usage') {
            xml.send('usage-compiler') { xml.name @usage_compiler }
            xml.send('compiled-period') { xml.start @period_start; xml.end @period_end }
            xml.send('contracting-party') {
              xml.send('non-municipality') {
                xml.name @contracting_party
                xml.send('education-provider') {
                  xml.send('educator-name', @educator_name)
                  @products.each_pair { |product_id,order_ids|
                    xml.product('product-id' => product_id) {
                      order_ids.each_pair { |order_id, count|
                        xml.streams(count, 'order-id' => order_id)
                      }
                    }
                  }
                }
              }
            }
          }
        end

        return builder.to_xml
      else
        puts "Specified Wowza access log (#{@wowza_access_log}) doesn’t exist."
        exit 1
      end
    end
  end
end
