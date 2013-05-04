module BoshVerifyManifest
  module Infections

    Hash.infect_an_assertion :assert_fills_resource_pools, 'must_fill_resource_pools', :only_one_argument
    Hash.infect_an_assertion :assert_has_name, 'must_be_named', :only_one_argument
    Hash.infect_an_assertion :assert_job_addresses_are_appropriate, 'must_have_appropriate_job_addresses', :only_one_argument
    Hash.infect_an_assertion :assert_specifies_director_uuid, 'must_specify_director_uuid', :only_one_argument
    Array.infect_an_assertion :assert_subnets_are_consistent, 'must_have_consistent_subnets', :only_one_argument
    Hash.infect_an_assertion :refute_exceeds_resource_pools, 'wont_exceed_resource_pools', :only_one_argument
    Hash.infect_an_assertion :assert_declares_all_resource_pools, 'must_declare_all_resource_pools', :only_one_argument

  end
end
