require 'ipaddr'
require 'uuidtools'
require 'yaml'

module BoshVerifyManifest
  module Assertions

    include Helpers

    def assert_declares_all_resource_pools(manifest)
      undeclared_pools(manifest).each do |pool|
        flunk "The '#{pool}' pool referred to does not exist"
      end
    end

    def assert_fills_resource_pools(manifest)
      usage = pool_usage(manifest)
      pool_sizes(manifest).each_pair do |pool, instances|
        assert instances == usage[pool],
          "The '#{pool}' pool is not full (size: #{instances}, wanted: #{usage[pool]})"
      end
    end

    def assert_has_name(manifest)
      assert manifest.key?('name'), 'The manifest does not have a name'
    end

    def assert_job_addresses_are_appropriate(manifest)
      manifest['jobs'].each do |job|
        job['networks'].select{|n| n['static_ips']}.each do |network|
          ranges = network(manifest, network['name'])['subnets'].map{|s| s['range']}
	  assert ranges.any?{|r| addresses_in_range?(network['static_ips'], r)},
            "The job '#{job['name']}' has static_ips that are not valid for the network '#{network['name']}'"
        end
      end
    end

    def assert_range_includes_gateway(subnet)
      if subnet['gateway']
        assert IPAddr.new(subnet['range']).include?(IPAddr.new(subnet['gateway']))
      end
    end

    def assert_specifies_director_uuid(manifest)
      assert manifest.key?('director_uuid'), 'The manifest does not specify the UUID of the bosh director'
      begin
        UUIDTools::UUID.parse(manifest['director_uuid'])
      rescue ArgumentError
        flunk 'The bosh director UUID is not a well-formed UUID'
      end
    end

    def assert_subnet_addresses_in_range(subnet)
      %w{reserved static}.each do |address_type|
        Array(subnet[address_type]).each do |addresses|
          assert addresses_in_range?(addresses, subnet['range']),
            "The subnet #{address_type} addresses are not within the range #{subnet['range']}"
        end
      end
    end

    def assert_subnet_ranges_do_not_overlap(subnets)
      ranges = subnets.map{|s| s['range']}
      ranges.permutation(2).each do |range_a, range_b|
        refute IPAddr.new(range_a).include?(IPAddr.new(range_b)),
          "The subnet ranges #{[range_a, range_b].sort.join(' and ')} overlap"
      end
    end

    def assert_subnets_are_consistent(networks)
      networks.each do |network|
        if network['subnets']
          network['subnets'].each do |subnet|
            assert_range_includes_gateway(subnet)
	    assert_subnet_addresses_in_range(subnet)
          end
          assert_subnet_ranges_do_not_overlap(network['subnets'])
        end
      end
    end

    def refute_exceeds_resource_pools(manifest)
      usage = pool_usage(manifest)
      pool_sizes(manifest).each_pair do |pool, instances|
        assert instances >= usage[pool],
          "The '#{pool}' pool is not large enough (size: #{instances}, wanted: #{usage[pool]})"
      end
    end

  end

end
