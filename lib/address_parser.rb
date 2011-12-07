# encoding: utf-8
require 'address_parser/version'

module AddressParser
  class Address
    attr_reader :input, :prefix, :first_name, :last_name, :company, :street, :zip, :city, :phone, :fax, :web, :email, :country
    
    def initialize(text)
      @input = text
      @plain = text
      
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
  
    def parse!
      parse_country
      parse_company
      parse_name
      parse_street
      parse_city_and_zip
      parse_phone
      parse_fax
      parse_email
      parse_web
    end

    def parse_country
      @country = nil
      
      if m = @plain.match(/(Germany|Deutschland)/i)
        @country = 'Germany'
        
        # Remove country name
        @plain.gsub!(m[1],'')
      end
      
      # For now, always assume german address
      @country = 'Germany'
    end

    def parse_company
      @company = nil
      if m = @plain.match(/(^.*(GmbH|mbh|OHG|KG|GbR|AG|UG|haftungsbeschränkt)$)/i)
        @company = m[1].strip
      end
    end
      
    def parse_name
      @prefix = nil
      if m = @plain.match(/^(Dr\.|Prof\.|Dipl\.\-.+?\b\.)+[^\d]*$/i)
        @prefix = m[1].strip
      end

      # TODO: This is far too simple and needs a lot of work ....
      @plain.gsub!(@company.to_s,'')
      @plain.gsub!(@prefix.to_s,'')
      first_line = @plain.lines.first.to_s
      words = first_line.split(' ')
      @first_name = words[0]
      @last_name = words[1]
      ###
    end
    
    def parse_street
      @street = nil
      
      if m = @plain.match(/^([a-zäöüÄÖÜß\ \.\-]+?)(\s+)(\d+\ *[a-z]*)/i)
        @street = (m[1] + ' ' + m[3]).strip
      end
    end
    
    def parse_city_and_zip
      @zip, @city = nil

      if m = @plain.match(/(\d{5})\s*([a-züöäÜÖÄß\s\-\.\/\(\)]+?)$/i)
        @zip = m[1]
        @city = m[2]
        
        @city.gsub!(/[\/\ ]*$/,'') # Remove some trailing non-word-characters from city
      end
    end
    
    def parse_phone
      @phone = nil

      if m = @plain.match(/(Fon|Phon|Phone|Tel|Telefon|Telefone|Telephone|Mobil|Mobile|Handy|Cell)[\.:\ ]*([\d\s\+\(\)\/\-\.]+)/i)
        @phone = m[2].strip
      end
    end
    
    def parse_fax
      @fax = nil

      if m = @plain.match(/(Fax|Telefax)[\.:\ ]*([\d\s\+\(\)\/\-\.]+)/i)
        @fax = m[2].strip
      end
    end
   
    def parse_email
      @email = nil

      if m = @plain.match(/([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/i)
        @email = m[1] + '@' + m[2]
      end
    end
    
    def parse_web
      @web = nil

      if m = @plain.match(/(http|https|www)(\S+)/)
        @web = "#{m[1]}#{m[2]}"
      end
    end
  end
end