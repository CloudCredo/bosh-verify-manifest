require 'ipaddr'

module BoshVerifyManifest
  module Assertions
    module Helpers

      def addresses_in_range?(addresses, range)
	unless range.include?('/') and range =~ %r{/[0-9]+$}
          raise ArgumentError, 'Range must be specified in CIDR format.'
        end
        # Can't get the netmask from an IPAddr instance without monkey patching
	# Consider using an alternate library for this functionality
        mask = range.split('/').last.to_i
        if addresses.include?('-')
          first_and_last_addresses = addresses.split('-').map do |address|
	    IPAddr.new(address.strip).to_s
	  end.uniq
          expanded_range = IPAddr.new(range).to_range.to_a.map{|i| i.to_s}
          (first_and_last_addresses & expanded_range) == first_and_last_addresses
        else
          Array(addresses).all? do |address|
            if address.include?('-')
              addresses_in_range?(address, range)
            else
              IPAddr.new(range).include?(address)
            end
          end
        end
      end

      def network(manifest, name)
        manifest['networks'].find{|n| n['name'] == name} || raise(
	  "Network '#{name}' not found in the manifest")
      end

      def pool_names(manifest)
        manifest['resource_pools'].map{|pool| pool['name']}
      end

      def pool_sizes(manifest)
        Hash[manifest['resource_pools'].map{|pool| [pool['name'], pool['size']]}]
      end

      def pool_usage(manifest)
        Hash[manifest['jobs'].group_by do |job|
          job['resource_pool']
        end.map do |pool, jobs|
          [pool, jobs.inject(0){|count, job| count += job['instances']}]
        end]
      end

      def undeclared_pools(manifest)
        pool_usage(manifest).keys.sort - pool_names(manifest).sort
      end

    end
  end
end
