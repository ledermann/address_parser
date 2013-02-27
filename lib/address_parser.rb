# encoding: utf-8
require 'address_parser/version'

module AddressParser
  class Address
    attr_accessor :input, :parts
    
    def initialize(text)
      @input = text
      @plain = text
      @parts = {}
      
      prepare!
      parse!
    end
    
  private
    def prepare!
      @plain = @plain.to_s.
                 lines.
                 map(&:strip).                        # Strip spaces from all lines
                 select { |line| line !=~ /\S/ }.     # Remove blank lines
                 join("\n")
    end
    
    # Remove given string and cleanup again
    def remove(string)
      @plain.gsub!(string,'')
      prepare!
    end
  
    def parse!
      parse_country
      parse_phone
      parse_fax
      parse_email
      parse_web
      parse_city_and_zip
      parse_street
      parse_company
      parse_name
    end

    def parse_country
      if m = @plain.match(/(Germany|Deutschland)/i)
        @parts[:country] = 'DE'
        remove(m.to_s)
      end
      
      # For now, always assume german address
      @parts[:country] = 'DE'
    end

    def parse_company
      if m = @plain.match(/(^.*(GmbH|mbh|OHG|KG|GbR|AG|UG|haftungsbeschränkt)$)/i)
        @parts[:company] = m[1].strip
        remove(m.to_s)
      end
    end
      
    def parse_name
      if m = @plain.match(/^(Dr\.|Prof\.|Dipl\.\-.+?\b\.)+[^\d]*$/i)
        @parts[:prefix] = m[1].strip
      end

      # TODO: This is far too simple and needs a lot of work ....
      @plain.gsub!(@parts[:company].to_s,'')
      @plain.gsub!(@parts[:prefix].to_s,'')
      first_line = @plain.lines.first.to_s
      words = first_line.split(' ')
      @parts[:first_name] = words[0] if words[0]
      @parts[:last_name] = words[1] if words[1]
      ###
    end
    
    def parse_street
      if m = @plain.match(/^([a-zäöüÄÖÜß\ \.\-]+?)(\ +)(\d+\ *[a-z]*)/i)
        @parts[:street] = (m[1] + ' ' + m[3]).strip
        remove(m.to_s)
      end
    end
    
    def parse_city_and_zip
      if m = @plain.match(/(\d{5})\ *([a-züöäÜÖÄß\ \-\.\/\(\)]+?)$/i)
        @parts[:zip] = m[1]

        @parts[:city] = m[2]
        @parts[:city].gsub!(/[\/\ ]*$/,'') # Remove some trailing non-word-characters from city
        
        remove(m.to_s)
      end
    end
    
    def parse_phone
      if m = @plain.match(/(Fon|Phon|Phone|Tel|Telefon|Telefone|Telephone|Mobil|Mobile|Handy|Cell)(nummer|number)?[\.:\s]*([\d\s\+\(\)\/\-\.]+)/i)
        @parts[:phone] = m[3].strip
        remove(m.to_s)
      end
    end
    
    def parse_fax
      if m = @plain.match(/(Fax|Telefax)(nummer|number)?[\.:\ ]*([\d\s\+\(\)\/\-\.]+)/i)
        @parts[:fax] = m[3].strip
        remove(m.to_s)
      end
    end
   
    def parse_email
      if m = @plain.match(/([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/i)
        @parts[:email] = m[1] + '@' + m[2]
        remove(m.to_s)
      end
    end
    
    def parse_web
      if m = @plain.match(/(http|https|www)(\S+)/)
        @parts[:web] = "#{m[1]}#{m[2]}"
        remove(m.to_s)
      end
    end
  end
end