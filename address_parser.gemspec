# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'address_parser/version'

Gem::Specification.new do |s|
  s.name        = 'address_parser'
  s.version     = AddressParser::VERSION
  s.authors     = ['Georg Ledermann']
  s.email       = ['mail@georg-ledermann.de']
  s.homepage    = ''
  s.summary     = %q{Ruby gem for parsing a (multiline) string containing an address and identifying its parts with Regex.}
  s.description = %q{It's useful to copy & paste contact or address informations from unformatted source (e.g. a website) into your schema based database.}

  s.rubyforge_project = 'address_parser'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
