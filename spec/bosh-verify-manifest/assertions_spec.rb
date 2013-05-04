require_relative '../spec_helper'
require 'ipaddr'

describe 'bosh-verify-manifest' do

  include BoshVerifyManifest::Assertions
  include BoshVerifyManifest::Infections

  describe(:name) do
    it "asserts that the manifest has a name" do
      assert_triggered("The manifest does not have a name") do
        {}.must_be_named
      end
    end
    it "succeeds if the manifest has a name" do
      {'name' => 'foo'}.must_be_named
    end
  end

  describe(:director_uuid) do
    it "asserts that the manifest specifies the UUID of a director" do
      assert_triggered("The manifest does not specify the UUID of the bosh director") do
        {}.must_specify_director_uuid
      end
    end
    it "asserts that the director uuid is well-formed" do
      assert_triggered("The bosh director UUID is not a well-formed UUID") do
        {'director_uuid' => '9ebffcaa-bed4'}.must_specify_director_uuid
      end
    end
    it "succeeds if the manifest specifies the UUID of a director" do
      {'director_uuid' => '9ebffcaa-bed4-46b6-8a37-8ca9a43bc817'}.must_specify_director_uuid
    end
  end

  describe(:static_addresses) do

    it "succeeds if no subnets are specified" do
      [{'name' => 'default', 'type' => 'dynamic'}].must_have_consistent_subnets
    end

    it "succeeds if subnet addresses are within the specified range" do
      example_networks.must_have_consistent_subnets
    end

    it "succeeds if no gateway is specified" do
      networks = example_networks.tap do |networks|
        networks.first['subnets'].first.delete('gateway')
      end
      networks.must_have_consistent_subnets
    end

    it "succeeds if no static addresses are specified" do
      networks = example_networks.tap do |networks|
        networks.first['subnets'].first.delete('static')
      end
      networks.must_have_consistent_subnets
    end

    it "succeeds if the static addresses are a range of one" do
      networks = example_networks.tap do |networks|
        networks.first['subnets'].first['static'][0] = '192.168.0.10 - 192.168.0.10'
      end
      networks.must_have_consistent_subnets
    end

    it "asserts that the static addresses are within the subnet range" do
      networks = example_networks.tap do |networks|
        networks.first['subnets'].first['static'][0] = '192.168.0.10 - 195.168.0.149'
      end
      assert_triggered("The subnet static addresses are not within the range 192.168.0.0/24") do
        networks.must_have_consistent_subnets
      end
    end

    it "asserts that the static addresses are within the subnet range" do
      networks = example_networks.tap do |networks|
        networks.first['subnets'].first['range'] = '192.168.0.0/28'
      end
      assert_triggered("The subnet static addresses are not within the range 192.168.0.0/28") do
        networks.must_have_consistent_subnets
      end
    end
  end

  describe(:overlapping_subnet_ranges) do
    it "asserts that subnets do not overlap" do
      networks = example_networks.tap do |networks|
        networks.first['subnets'] << networks.first['subnets'].first.clone
	networks.first['subnets'].last['range'] = '192.168.0.0/16'
      end
      assert_triggered("The subnet ranges 192.168.0.0/16 and 192.168.0.0/24 overlap") do
        networks.must_have_consistent_subnets
      end
    end
    it "suceeds if subnets do not overlap" do
      networks = example_networks.tap do |networks|
	networks.first['subnets'] << {'static' => ['192.168.2.2 - 192.168.2.254'],
          'range' => '192.168.2.0/24', 'gateway' => '192.168.2.1'}
      end
      networks.must_have_consistent_subnets
    end

  end

  describe(:job_static_addresses) do
    it "asserts that static addresses are appropriate for the network" do
      manifest = {
        'networks' => example_networks,
        'jobs' => [{'name' => 'redis_gateway',
          'networks' => [{'name' => 'default', 'static_ips' => ['192.168.2.14']}]}]
      }
      assert_triggered("The job 'redis_gateway' has static_ips that are not valid for the network 'default'") do
        manifest.must_have_appropriate_job_addresses
      end
    end
    it "succeeds if static addresses are appropriate for the network" do
      manifest = {
        'networks' => example_networks,
        'jobs' => [{'name' => 'redis_gateway',
          'networks' => [{'name' => 'default', 'static_ips' => ['192.168.0.14']}]}]
      }
      manifest.must_have_appropriate_job_addresses
    end
    it "succeeds if jobs don't specify static addresses" do
      manifest = {
        'networks' => example_networks,
        'jobs' => [{'name' => 'redis_gateway',
          'networks' => [{'name' => 'default'}]}]
      }
      manifest.must_have_appropriate_job_addresses
    end
  end

  describe(:resource_pool_size) do
    it "asserts that resource pools must be large enough for job instances" do
      manifest = {
	'resource_pools' => [{'name' => 'infrastructure', 'size' => 5}],
        'jobs' => [
          {'resource_pool' => 'infrastructure', 'name' => 'debian_nfs_server', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'nats', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'dea', 'instances' => 4}
        ]
      }
      assert_triggered("The 'infrastructure' pool is not large enough (size: 5, wanted: 6)") do
        manifest.wont_exceed_resource_pools
      end
    end
    it "succeeds if the resource pool is large enough" do
      manifest = {
	'resource_pools' => [{'name' => 'infrastructure', 'size' => 6}],
        'jobs' => [
          {'resource_pool' => 'infrastructure', 'name' => 'debian_nfs_server', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'nats', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'dea', 'instances' => 4}
        ]
      }
      manifest.wont_exceed_resource_pools
    end
  end

  describe(:resource_pools_underused) do
    it "asserts that resource pools must be fully used" do
      manifest = {
	'resource_pools' => [{'name' => 'infrastructure', 'size' => 5}],
        'jobs' => [
          {'resource_pool' => 'infrastructure', 'name' => 'debian_nfs_server', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'nats', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'dea', 'instances' => 2}
        ]
      }
      assert_triggered("The 'infrastructure' pool is not full (size: 5, wanted: 4)") do
        manifest.must_fill_resource_pools
      end
    end
    it "succeeds if the resource pool is fully used" do
      manifest = {
	'resource_pools' => [{'name' => 'infrastructure', 'size' => 5}],
        'jobs' => [
          {'resource_pool' => 'infrastructure', 'name' => 'debian_nfs_server', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'nats', 'instances' => 1},
          {'resource_pool' => 'infrastructure', 'name' => 'dea', 'instances' => 3}
        ]
      }
      manifest.must_fill_resource_pools
    end
  end

  describe(:unknown_resource_pool) do
    it "asserts that all resource pools referred to have been declared" do
      manifest = {
	'resource_pools' => [{'name' => 'infrastructure', 'size' => 5}],
        'jobs' => [
          {'resource_pool' => 'infrastructuer', 'name' => 'debian_nfs_server', 'instances' => 1},
        ]
      }
      assert_triggered("The 'infrastructuer' pool referred to does not exist") do
        manifest.must_declare_all_resource_pools
      end
    end
    it "succeeds if all resource pools referred to have been declared" do
      manifest = {
	'resource_pools' => [{'name' => 'infrastructure', 'size' => 5}],
        'jobs' => [
          {'resource_pool' => 'infrastructure', 'name' => 'debian_nfs_server', 'instances' => 1},
        ]
      }
      manifest.must_declare_all_resource_pools
    end

  end

end
