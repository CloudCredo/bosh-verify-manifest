require 'minitest/spec'
require 'bosh-verify-manifest/helpers'
require 'bosh-verify-manifest/assertions'

module Bosh::Cli::Command
  class VerifyManifest < Base

    include MiniTest::Assertions
    include BoshVerifyManifest::Assertions

    def manifest
      @manifest ||= YAML::load(File.read(deployment))
    end

    usage "verify manifest"
    desc "Check the BOSH manifest for common errors"
    def verify_manifest
      deployment_required
      begin
        assert_has_name(manifest)
        assert_specifies_director_uuid(manifest)
        assert_subnets_are_consistent(manifest['networks'])
        assert_job_addresses_are_appropriate(manifest)
        assert_declares_all_resource_pools(manifest)
        refute_exceeds_resource_pools(manifest)
        assert_fills_resource_pools(manifest)
      rescue MiniTest::Assertion => a
        err a.to_s
      end
    end

  end
end
