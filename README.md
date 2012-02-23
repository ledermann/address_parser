# AddressParser

[![Build Status](https://secure.travis-ci.org/ledermann/address_parser.png)](http://travis-ci.org/ledermann/address_parser)

Ruby gem for parsing a (multiline) string containing an address and identifying its parts with Regex. It's useful to copy & paste contact or address informations from unformatted source (e.g. a website) into your schema based database.

**Beware:** This project is in early alpha state and needs a lot of work to be useful. So far it's just a project started on a rainy weekend. I'm not sure about its future.


## Installation

Add this to your Gemfile:

    gem 'address_parser', :git => 'git://github.com/ledermann/address_parser.git'

(not released to rubygems.org, yet)

## Usage

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

A lot of variants are recognized


## Limitations

* It uses **no** databases (e.g. for first names or cities), so it can't be perfect
* It recognizes only german addresses (yet)
* It does not format any phone numbers. If you need this, look at additional Ruby gems like [Phony](https://github.com/floere/phony) or [Dialy](https://github.com/ledermann/dialy)


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. No discussion. No tests, no game. We use rspec for testing.
* Commit, do not mess with rakefile, version, or history. If you want to have your own version, thats fine. But bump your version in a seperate commit that can be ignored when pulling.
* Send me a pull request. Bonus points for topic branches.


## References

There is a commercial alternative named [RecogniContact](http://address-parser.com) which is **much more** powerful - but closed source.


## Copyright

Copyright © 2011,2012 [Georg Ledermann](http://georg-ledermann.de). See LICENSE for details.