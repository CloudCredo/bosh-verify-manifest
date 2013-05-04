lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'bosh-verify-manifest/version'
Gem::Specification.new do |s|
  s.name = 'bosh-verify-manifest'
  s.version = BoshVerifyManifest::VERSION
  s.description = 'Validate BOSH deployment manifests.'
  s.summary = "bosh-verify-manifest-#{s.version}"
  s.authors = ['Andrew Crump']
  s.homepage = 'http://github.com/cloudcredo/bosh-verify-manifest'
  s.license = 'MIT'
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('bosh_cli')
  s.add_dependency('minitest', '~> 4.7.4')
  s.add_dependency('uuidtools', '~> 2.1.3')
end
