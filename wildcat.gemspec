# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = "wildcat"
  s.summary       = "CMS and blogging system that generates static pages"
  s.version       = "0.0.1"
  s.author        = "Brent Simmons"
  s.homepage      = "https://github.com/brentsimmons/wildcat"
  s.files         = `git ls-files`.strip.split(/\s+/).reject {|f| f.match(%r{^test/}) }
  s.require_paths = ["."]

  s.add_dependency "kramdown"
  s.add_dependency "stringex"
end
