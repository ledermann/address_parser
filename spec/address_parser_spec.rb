# encoding: utf-8
require 'spec_helper'

describe AddressParser do
  context 'german address' do
    describe 'full address' do
      it 'should recognize person' do
        address = AddressParser::Address.new <<-EOT
          Peter Meier
          Marienburger Straße 29
          50374 Erftstadt
          Fon (02235) 123456
          Fax (02235) 654321
          Web www.peter-meier.de
          E-Mail mail@peter-meier.de
        EOT
      
        expect(address.parts).to eq({
          :first_name     => 'Peter',
          :last_name      => 'Meier',
          :street         => 'Marienburger Straße 29',
          :zip            => '50374',
          :city           => 'Erftstadt',
          :country        => 'DE',
          :phone          => '(02235) 123456',
          :fax            => '(02235) 654321',
          :web            => 'www.peter-meier.de',
          :email          => 'mail@peter-meier.de'
        })
      end
    
      it 'should recognize company' do
        address = AddressParser::Address.new <<-EOT
          A&B Computing GmbH 

          Schwarzpfeilweg 50 
          72086 Blutwurst - Unterburg
          Telefon 06132 / 3680-0
          Telefax 06132 / 3680-20
          Email: info@aundbcomputing.de
        EOT
      
        expect(address.parts).to eq({
          :company    => 'A&B Computing GmbH',
          :street     => 'Schwarzpfeilweg 50',
          :zip        => '72086',
          :city       => 'Blutwurst - Unterburg',
          :country    => 'DE',
          :phone      => '06132 / 3680-0',
          :fax        => '06132 / 3680-20',
          :email      => 'info@aundbcomputing.de'
        })
      end
    end
    
    describe 'incomplete address' do
      it 'should handle prefix, name, phone, email' do
        address = AddressParser::Address.new <<-EOT
          dipl.-ing. eva meier

          telefon +49 241 87528-22
          eva.maier@meier.de
        EOT
      
        expect(address.parts).to eq({
          :prefix     => 'dipl.-ing.',
          :first_name => 'eva',
          :last_name  => 'meier',
          :country    => 'DE',
          :phone      => '+49 241 87528-22',
          :email      => 'eva.maier@meier.de'
        })
      end
      
      it 'should handle name, city' do
        address = AddressParser::Address.new <<-EOT
          Eva Meier
          50999 Köln
        EOT
      
        expect(address.parts).to eq({
          :first_name => 'Eva',
          :last_name  => 'Meier',
          :zip        => '50999',
          :city       => 'Köln',
          :country    => 'DE'
        })
      end
      
      it 'should handle name, street' do
        address = AddressParser::Address.new <<-EOT
          Eva Meier
          Hauptstraße 10
        EOT
      
        expect(address.parts).to eq({
          :first_name => 'Eva',
          :last_name  => 'Meier',
          :street     => 'Hauptstraße 10',
          :country    => 'DE'
        })
      end
      
      it 'should handle street, zip, city' do
        address = AddressParser::Address.new <<-EOT
          Hauptstraße 10
          50999 Köln
        EOT
      
        expect(address.parts).to eq({
          :street     => 'Hauptstraße 10',
          :zip        => '50999',
          :city       => 'Köln',
          :country    => 'DE'
        })
      end
      
      it 'should handle phone, e-mail' do
        address = AddressParser::Address.new <<-EOT
          Fon 01122/223344
          info@foo.bar
        EOT
      
        expect(address.parts).to eq({
          :phone      => '01122/223344',
          :email      => 'info@foo.bar',
          :country    => 'DE'
        })
      end
    end
  end
  
  describe 'blank input' do
    it 'should not raise error' do
      expect {
        AddressParser::Address.new(nil)
        AddressParser::Address.new('')
      }.not_to raise_error
    end
  end
  
  describe 'input' do
    it 'should return original string' do
      input = 'Dr. Peter Müller'
      address = AddressParser::Address.new(input)
      expect(address.input).to eq(input)
    end
  end
  
  describe 'name and prefix' do
    { 'Peter Meier'                 => [ nil,              'Peter',      'Meier' ],
      'Peter Meier-Müller'          => [ nil,              'Peter',      'Meier-Müller' ],
      'Dr. Hans-Peter Meier-Müller' => [ 'Dr.',            'Hans-Peter', 'Meier-Müller' ],
      # 'Dr. Dr. Peter Meier'         => [ 'Dr. Dr.',        'Peter',      'Meier' ],
      # 'Prof. Dr. Peter Meier'       => [ 'Prof. Dr.',      'Peter',      'Meier' ],
      # 'Prof. Dr. Dr. Peter Meier'   => [ 'Prof. Dr. Dr.',  'Peter',      'Meier' ],
      # 'Dr.-Ing. Peter Meier'        => [ 'Dr.-Ing',        'Peter',      'Meier' ],
      # 'Prof. Dr.-Ing. Peter Meier'  => [ 'Prof. Dr.-Ing.', 'Peter',      'Meier' ]
    }.each_pair do |sample, expected|
      it "should recognize '#{sample}'" do
        address = AddressParser::Address.new("#{sample}\nfoo\nbar")
        expect(address.parts[:prefix]).to     eq(expected[0])
        expect(address.parts[:first_name]).to eq(expected[1])
        expect(address.parts[:last_name]).to  eq(expected[2])
      end
    end
  end
  
  describe 'street' do
    [ 'Marienburger Str. 29',
      'Marienburger Str. 29a',
      'Marienburger Straße 29a',
      'Marienburger Straße 29 a',
      'Prof.-Dr.-Müller-Straße 172b',
      'Platz der Republik 1'
    ].each do |sample|
      it "should recognize '#{sample}'" do
        expect(AddressParser::Address.new("foo\n#{sample}\nbar").parts[:street]).to eq(sample)
      end
    end
  end
  
  describe 'city and zip' do
    { '50374 Erftstadt'      => [ '50374', 'Erftstadt' ],
      '50999 Köln'           => [ '50999', 'Köln' ],
      'D-50999 Köln'         => [ '50999', 'Köln' ],
      '01067 Dresden'        => [ '01067', 'Dresden' ],
      '60999 Frankfurt/Main' => [ '60999', 'Frankfurt/Main' ],
      '06114 Halle (Saale)'  => [ '06114', 'Halle (Saale)' ]
    }.each_pair do |sample,expected|
      it "should recognize '#{sample}'" do
        address = AddressParser::Address.new("foo\n#{sample}\nbar")
        expect(address.parts[:zip]).to eq(expected[0])
        expect(address.parts[:city]).to eq(expected[1])
      end
    end
  end
  
  describe 'email' do
    { 'mail info@meier.de'           => 'info@meier.de',
      'E-Mail: info@meier.de'        => 'info@meier.de',
      'peter.meier@peter-meier.com'  => 'peter.meier@peter-meier.com'
    }.each_pair do |sample,expected|
      it "should recognize '#{sample}'" do
        expect(AddressParser::Address.new("foo\n#{sample}\nbar").parts[:email]).to eq(expected)
      end
    end
  end
  
  PHONE_NUMBERS = [ 
    '02233/12345',
    '(02233) 12345',
    '02233-12345',
    '02233.12345',
    '+49-2233-12345'
  ]
  
  describe 'phone' do
    [ 'Fon ',
      'Tel ',
      'Mobil ',
      'Tel. ',
      'Telefon: ',
      'Telefonnummer:',
      'Mobilnummer'
    ].each do |prefix|
      PHONE_NUMBERS.each do |number|
        it "should recognize '#{prefix}#{number}'" do
          expect(AddressParser::Address.new("foo\n#{prefix}#{number}\nbar").parts[:phone]).to eq(number)
        end
      end
    end
  end
  
  describe 'fax' do
    ['Fax ',
     'Telefax ',
     'Faxnummer:'
    ].each do |prefix|
      PHONE_NUMBERS.each do |number|
        it "should recognize '#{prefix}#{number}'" do
          expect(AddressParser::Address.new("foo\n#{prefix}#{number}\nbar").parts[:fax]).to eq(number)
        end
      end
    end
  end
  
  describe 'web' do
    { 'Web www.peter-meier.de'        => 'www.peter-meier.de',
      'Web http://peter-meier.de'     => 'http://peter-meier.de',
      'Web http://www.peter-meier.de' => 'http://www.peter-meier.de',
      #'Web peter-meier.de'            => 'peter-meier.de',
      'www.peter-meier.de'            => 'www.peter-meier.de'
    }.each_pair do |sample,expected|
      it "should recognize '#{sample}'" do
        expect(AddressParser::Address.new("foo\n#{sample}\nbar").parts[:web]).to eq(expected)
      end
    end
  end
end