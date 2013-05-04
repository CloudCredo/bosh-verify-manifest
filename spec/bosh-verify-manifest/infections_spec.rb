require_relative '../spec_helper'

module BoshVerifyManifest
  describe Infections do
    it "makes the expected matchers available on the manifest" do
      %w{
	must_be_named
	must_declare_all_resource_pools
        must_fill_resource_pools
	must_have_appropriate_job_addresses
	must_specify_director_uuid
	wont_exceed_resource_pools
      }.each{|matcher| assert({}.respond_to?(matcher.to_sym))}
    end
    it "makes the expected matchers available on the networks section" do
      assert([].respond_to?(:must_have_consistent_subnets))
    end
  end
end
