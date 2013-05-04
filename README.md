# BOSH Verify Manifest

## Usage

Making errors when editing BOSH manifests is common. Waiting for errors to become
apparent by running `bosh deploy` is slow.

This gem aims to speed up the feedback cycle when editing BOSH manifests by
running checks against your manifests locally.

### Command Line

Once you have installed the `bosh-verify-manifest` gem a new bosh sub-command
will be available:

```
$ gem install bosh-verify-manifest
$ bosh help verify
verify manifest
    Check the BOSH manifest for common errors
```

This command acts on the deployment that you have selected with
`bosh deployment`.

```
$ bosh deployment ./path/to/deployment/manifest.yml
$ bosh verify manifest
```

### MiniTest

As an alternative to using the command line interface you can use the built-in
support for verifying manifests from MiniTest.

For example you might combine the built-in checks with code that uses Fog to
compare the manifest against the environment you are deploying into.

#### Example

```ruby
# spec/example_spec.rb
require_relative 'spec_helper'

# Load the manifest 'example-deployment.yml'
describe_bosh_manifest 'example-deployment' do

  it { manifest.must_be_named }
  it { manifest.must_specify_director_uuid }

  # Checks that the subnet addresses are appropriate for the ranges specified,
  # and that the ranges do not overlap.
  it { manifest['networks'].must_have_consistent_subnets }

  # If static addresses are specified against the jobs this checks that the
  # addresses are valid for the networks the job can see.
  it { manifest.must_have_appropriate_job_addresses }

  it { manifest.must_declare_all_resource_pools }
  it { manifest.wont_exceed_resource_pools }

  # Use this check if you want to spawn the minimum instances necessary to
  # deploy the jobs.
  it { manifest.must_fill_resource_pools }

end
```

```ruby
# Gemfile
source "https://rubygems.org"

gem 'bosh-verify-manifest'
```

```ruby
# spec/spec_helper.rb
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'
require 'bosh-verify-manifest'
```

```
$ cp ./path/to/deployment/manifest.yml example-deployment.yml
$ ruby spec/example_spec.rb
```

## Building

```
$ bundle install
$ bundle exec rake
```

## License
MIT - see the accompanying [LICENSE](https://github.com/cloudcredo/bosh-verify-manifest/blob/master/LICENSE) file for details.

## Changelog
To see what has changed in recent versions see the [CHANGELOG](https://github.com/cloudcredo/bosh-verify-manifest/blob/master/CHANGELOG.md).
BOSH Verify Manifest follows the [Rubygems RationalVersioningPolicy](http://docs.rubygems.org/read/chapter/7).
