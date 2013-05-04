require_relative '../../../spec_helper'
require 'cli'
require_relative '../../../../lib/bosh/cli/commands/verify'

module Bosh
  module Cli
    module Command
      describe VerifyManifest do
        describe "#initialize" do
          it "can be instantiated without any arguments" do
            VerifyManifest.new
          end
	  it "accepts a runner" do
            VerifyManifest.new([])
	  end
        end

	describe :command_line do
	  it "exposes the verify manifest command" do
	    bosh_commands.map{|c| c.usage}.include?('verify manifest')
	  end
	  it "has a relevant description for the verify manifest command" do
            bosh_commands.find do |c|
	      c.usage == 'verify manifest'
	    end.desc.must_equal 'Check the BOSH manifest for common errors'
	  end
        end

	describe "#verify_manifest" do
          describe :manifest_with_errors do
            let(:v) do
              stub_empty_manifest(mock_deployment_required(VerifyManifest.new))
            end
            it "should error if a deployment is not currently selected" do
              begin
                v.verify_manifest
              rescue ::Bosh::Cli::CliError
              end
              assert v.deployment_checked?
            end
            it "raises a cli error if the manifest has errors" do
              assert_raises(::Bosh::Cli::CliError){ v.verify_manifest }
            end
	  end
	  describe :manifest_without_errors do
            let(:v) do
              stub_minimal_manifest(
	        mock_deployment_required(VerifyManifest.new))
            end
	    it "doesn't raise a cli error" do
              v.verify_manifest
            end
	  end
        end

        def bosh_commands
          Bosh::Cli::Config.commands.values
	end

        def mock_deployment_required(cmd)
	  def cmd.deployment_checked?
            @deployment_checked
	  end
	  def cmd.deployment_required
            @deployment_checked = true
	  end
	  cmd
        end

	def stub_empty_manifest(cmd)
	  def cmd.manifest
            {}
	  end
	  cmd
	end

	def stub_minimal_manifest(cmd)
	  def cmd.manifest
            {'name' => 'foo',
             'director_uuid' => 'c8ab5809-6cfd-47cf-9fcf-1c66fd35273d',
	     'networks' => example_networks,
	     'jobs' => [],
	     'resource_pools' => []}
	  end
	  cmd
	end

      end
    end
  end
end
