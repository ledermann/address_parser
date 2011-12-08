# encoding: utf-8
require 'spec_helper'

describe AddressParser do
  context 'german address' do
    it 'should recognize full address' do
      address = AddressParser::Address.new <<-EOT
        Peter Meier
        Marienburger Straße 29
        50374 Erftstadt
        Fon (02235) 123456
        Fax (02235) 654321
        Web www.peter-meier.de
        E-Mail mail@peter-meier.de
      EOT
      
      address.parts.should == {
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
      }
    end
    
    it 'should recognize full address' do
      address = AddressParser::Address.new <<-EOT
        A&B Computing GmbH 

        Schwarzpfeilweg 50 
        72086 Blutwurst - Unterburg
        Telefon 06132 / 3680-0
        Telefax 06132 / 3680-20
        Email: info@aundbcomputing.de
      EOT
      
      address.parts.should == {
        :company    => 'A&B Computing GmbH',
        :street     => 'Schwarzpfeilweg 50',
        :zip        => '72086',
        :city       => 'Blutwurst - Unterburg',
        :country    => 'DE',
        :phone      => '06132 / 3680-0',
        :fax        => '06132 / 3680-20',
        :email      => 'info@aundbcomputing.de'
      }
    end
    
    it 'should recognize incomplete address' do
      address = AddressParser::Address.new <<-EOT
        dipl.-ing. eva meier

        telefon +49 241 87528-22
        eva.maier@meier.de
      EOT
      
      address.parts.should == {
        :prefix     => 'dipl.-ing.',
        :first_name => 'eva',
        :last_name  => 'meier',
        :country    => 'DE',
        :phone      => '+49 241 87528-22',
        :email      => 'eva.maier@meier.de'
      }
    end
    
    it 'should recognize company address' do
      address = AddressParser::Address.new <<-EOT
        x+y meier ingenieurgesellschaft mbh
        metzgerstrasse 3
        52072 aachen / germany

        fon: +49 241 84428-0
        fax: +49 241 84428-25

        e-mail: meier@t-online.de
        internet: www.meier.de
      EOT
      
      address.parts.should == {
        :company => 'x+y meier ingenieurgesellschaft mbh',
        :street  => 'metzgerstrasse 3',
        :zip     => '52072',
        :city    => 'aachen',
        :country => 'DE',
        :phone   => '+49 241 84428-0',
        :fax     => '+49 241 84428-25',
        :web     => 'www.meier.de',
        :email   => 'meier@t-online.de'
      }
    end
  end
  
  describe 'blank input' do
    it 'should not raise error' do
      lambda {
        AddressParser::Address.new(nil)
        AddressParser::Address.new('')
      }.should_not raise_error
    end
  end
  
  describe 'input' do
    it 'should return original string' do
      input = 'Dr. Peter Müller'
      address = AddressParser::Address.new(input)
      address.input.should == input
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
        address.parts[:prefix].should     == expected[0]
        address.parts[:first_name].should == expected[1]
        address.parts[:last_name].should  == expected[2]
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
        AddressParser::Address.new("foo\n#{sample}\nbar").parts[:street].should == sample
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
        address.parts[:zip].should == expected[0]
        address.parts[:city].should == expected[1]
      end
    end
  end
  
  describe 'email' do
    { 'mail info@meier.de'           => 'info@meier.de',
      'E-Mail: info@meier.de'        => 'info@meier.de',
      'peter.meier@peter-meier.com'  => 'peter.meier@peter-meier.com'
    }.each_pair do |sample,expected|
      it "should recognize '#{sample}'" do
        AddressParser::Address.new("foo\n#{sample}\nbar").parts[:email].should == expected
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
      'Telefon: '
    ].each do |prefix|
      PHONE_NUMBERS.each do |number|
        it "should recognize '#{prefix}#{number}'" do
          AddressParser::Address.new("foo\n#{prefix}#{number}\nbar").parts[:phone].should == number
        end
      end
    end
  end
  
  describe 'fax' do
    ['Fax ',
     'Telefax '
    ].each do |prefix|
      PHONE_NUMBERS.each do |number|
        it "should recognize '#{prefix}#{number}'" do
          AddressParser::Address.new("foo\n#{prefix}#{number}\nbar").parts[:fax].should == number
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
        AddressParser::Address.new("foo\n#{sample}\nbar").parts[:web].should == expected
      end
    end
  end
end