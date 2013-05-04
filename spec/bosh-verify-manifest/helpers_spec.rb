require_relative '../spec_helper'

module BoshVerifyManifest
  module Assertions
    describe Helpers do
      let(:helpers) do
        Object.extend(Helpers)
      end
      describe "#addresses_in_range?" do
	describe :single_addresses do
	  it "returns true if a single address is in the range" do
            assert helpers.addresses_in_range?('192.168.0.1', '192.168.0.1/24')
          end
	  it "returns false if a single address is not in the range" do
            refute helpers.addresses_in_range?('8.8.8.8', '192.168.0.1/24')
          end
        end
	describe :multiple_addresses do
	  it "returns true if all addresses are in the range" do
            assert helpers.addresses_in_range?(['192.168.0.1', '192.168.0.2'], '192.168.0.1/24')
          end
	  it "returns false if any address is not in the range" do
            refute helpers.addresses_in_range?(['192.168.0.1', '8.8.8.8'], '192.168.0.1/24')
          end
	end
	describe :dashed_ranges do
          it "returns true if all addresses are in the range" do
            assert helpers.addresses_in_range?('192.168.0.1 - 192.168.0.2', '192.168.0.1/24')
          end
	  it "returns false if any address is not in the range" do
            refute helpers.addresses_in_range?('192.168.0.1 - 192.168.0.2', '192.168.0.1/32')
          end
	end
        it "raises if the range is not cidr" do
          err = assert_raises(ArgumentError){ helpers.addresses_in_range?('192.168.0.1', '192.168.0.1') }
	  err.message.must_equal 'Range must be specified in CIDR format.'
        end
	it "raises if the netmask is not numeric" do
          err = assert_raises(ArgumentError){ helpers.addresses_in_range?('192.168.0.1', '192.168.0.1/foo') }
	  err.message.must_equal 'Range must be specified in CIDR format.'
	end
	it "raises if any address is invalid" do
          proc{ helpers.addresses_in_range?(['192.168.0.1 - foo'], '192.168.0.1/24') }.must_raise ArgumentError
	end
      end

      describe "#network" do
	let(:manifest) do
          {'networks' => [{'name' => 'foo'}]}
	end
        it "returns the network of the specified name from the manifest" do
          helpers.network(manifest, 'foo').must_equal({'name' => 'foo'})
	end
        it "raises if a network of that name does not exist in the manifest" do
          err = assert_raises(RuntimeError){helpers.network(manifest, 'bar') }
          err.message.must_equal "Network 'bar' not found in the manifest"
	end
      end

      describe "#pool_names" do
	describe :no_pools do
          it "returns an empty if there are no resource pools" do
            helpers.pool_names({'resource_pools' => []}).must_be_empty
	  end
          it "returns the names of any resource pools defined" do
            helpers.pool_names({'resource_pools' => [{'name' => 'large'},
              {'name' => 'small'}]}).must_equal(['large', 'small'])
	  end
	end
      end

      describe "#pool_sizes" do
	describe :no_pools do
          it "returns an empty if there are no resource pools" do
            helpers.pool_sizes({'resource_pools' => []}).must_be_empty
	  end
          it "returns the names and size of any resource pools defined" do
            helpers.pool_sizes({'resource_pools' => [
	      {'name' => 'large', 'size' => 5},
              {'name' => 'small', 'size' => 10}
	    ]}).must_equal({'large' => 5, 'small' => 10})
	  end
	end
      end

      describe "#pool_usage" do
        it "returns an empty if there are no jobs" do
          helpers.pool_usage({'jobs' => []}).must_be_empty
        end
        it "totals the number of instances per pool" do
          helpers.pool_usage({'jobs' => [
	    {'name' => 'foo', 'resource_pool' => 'large', 'instances' => 2},
	    {'name' => 'bar', 'resource_pool' => 'large', 'instances' => 3},
	    {'name' => 'baz', 'resource_pool' => 'small', 'instances' => 3},
	  ]}).must_equal({'large' => 5, 'small' => 3})
        end
      end

      describe "#undeclared_pools" do
        it "returns an empty if all pools have been declared" do
          helpers.undeclared_pools({
	    'resource_pools' => [{'name' => 'large'}],
	    'jobs' => [{'name' => 'foo', 'resource_pool' => 'large', 'instances' => 2}]
	  }).must_be_empty
	end
	it "returns pools used by jobs but not declared" do
          helpers.undeclared_pools({
	    'resource_pools' => [{'name' => 'large'}],
	    'jobs' => [{'name' => 'baz', 'resource_pool' => 'small', 'instances' => 3}]
	  }).must_equal(['small'])
	end
      end

    end
  end
end
