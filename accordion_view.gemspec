# -*- encoding: utf-8 -*-
require File.expand_path('../lib/accordion_view/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Amit Kumar"]
  gem.email         = ["toamitkumar@gmail.com"]
  gem.description   = "Adding Accordion to your view"
  gem.summary       = "Adding Accordion to your view"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.name          = "accordion_view"
  gem.require_paths = ["lib"]
  gem.version       = AccordionView::VERSION

  gem.add_dependency "bubble-wrap"
  gem.add_development_dependency 'rake'
end