require_relative 'bosh-verify-manifest/helpers'
require_relative 'bosh-verify-manifest/assertions'
require_relative 'bosh-verify-manifest/infections'
require_relative 'bosh-verify-manifest/version'

module BoshVerifyManifest
  require 'minitest/spec'

  class Spec < MiniTest::Spec
    include Assertions
    include Infections

    def manifest_path
      "#{self.class.name.split('::').last}.yml"
    end

    def manifest
      YAML::load(File.read(manifest_path))
    end

  end

  MiniTest::Spec.register_spec_type(/^bosh_manifest::/, BoshVerifyManifest::Spec)
end

module Kernel
  def describe_bosh_manifest(desc, additional_desc = nil, &block)
    describe("bosh_manifest::#{desc}", additional_desc, &block)
  end
end
