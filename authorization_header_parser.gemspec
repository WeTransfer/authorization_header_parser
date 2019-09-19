require File.join(File.expand_path('../lib', __FILE__), 'authorization_header_parser')

Gem::Specification.new do |s|
  s.name = "authorization_header_parser"
  s.version = AuthorizationHeaderParser::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["WeTransfer"]
  s.date = "2015-06-29"
  s.description = "Parses parametrized  HTTP Authorization headers"
  s.email = "info@wetransfer.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = `git ls-files -z`.split("\x0")
  s.homepage = "http://github.com/wetransfer/authorization_header_parser"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "such as OAuth and Digest"

  s.specification_version = 4
  s.add_development_dependency('bundler')
  s.add_development_dependency('rspec', '~> 3')
  s.add_development_dependency('rake', '~> 10')
end
