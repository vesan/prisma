# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "prisma"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christof Dorner"]
  s.date = "2012-07-13"
  s.email = "christof@chdorner.me"
  s.executables = ["prisma-web"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "bin/prisma-web",
    "lib/prisma.rb",
    "lib/prisma/filter.rb",
    "lib/prisma/group.rb",
    "lib/prisma/railtie.rb",
    "lib/prisma/server.rb",
    "lib/prisma/server/public/bootstrap-responsive.min.css",
    "lib/prisma/server/public/bootstrap.min.css",
    "lib/prisma/server/public/reset.css",
    "lib/prisma/server/public/style.css",
    "lib/prisma/server/views/index.erb"
  ]
  s.homepage = "https://github.com/chdorner/prisma"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Simple request stats collector for Rails applications"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<redis-namespace>, [">= 1.0.2"])
      s.add_runtime_dependency(%q<redis>, [">= 2.2.0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<vegas>, ["~> 0.1.2"])
      s.add_runtime_dependency(%q<bitset>, [">= 0.1.0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.10.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<kramdown>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<guard-livereload>, [">= 0"])
      s.add_development_dependency(%q<rb-fsevent>, [">= 0"])
      s.add_development_dependency(%q<growl>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<shotgun>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.0.0"])
      s.add_dependency(%q<redis-namespace>, [">= 1.0.2"])
      s.add_dependency(%q<redis>, [">= 2.2.0"])
      s.add_dependency(%q<sinatra>, [">= 1.0.0"])
      s.add_dependency(%q<vegas>, ["~> 0.1.2"])
      s.add_dependency(%q<bitset>, [">= 0.1.0"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.10.0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<kramdown>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<guard-livereload>, [">= 0"])
      s.add_dependency(%q<rb-fsevent>, [">= 0"])
      s.add_dependency(%q<growl>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<shotgun>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.0.0"])
    s.add_dependency(%q<redis-namespace>, [">= 1.0.2"])
    s.add_dependency(%q<redis>, [">= 2.2.0"])
    s.add_dependency(%q<sinatra>, [">= 1.0.0"])
    s.add_dependency(%q<vegas>, ["~> 0.1.2"])
    s.add_dependency(%q<bitset>, [">= 0.1.0"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.10.0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<kramdown>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<guard-livereload>, [">= 0"])
    s.add_dependency(%q<rb-fsevent>, [">= 0"])
    s.add_dependency(%q<growl>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<shotgun>, [">= 0"])
  end
end

