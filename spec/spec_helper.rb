require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'

require_relative '../lib/bosh-verify-manifest'

# Borrowed from MiniTest
def assert_triggered(expected)
  e = assert_raises(MiniTest::Assertion) do
    yield
  end
  msg = e.message.sub(/(---Backtrace---).*/m, '\1')
  msg.gsub!(/\(oid=[-0-9]+\)/, '(oid=N)')

  if expected.is_a?(String)
    assert_includes msg, expected
  else
    assert_match expected, msg
  end
end

def example_networks
  YAML::load(%q{
    networks:
      - name: default
        subnets:
        - static:
          - 192.168.0.10 - 192.168.0.149
          range: 192.168.0.0/24
          gateway: 192.168.0.1
          dns:
          - 8.8.8.8
  }.strip)['networks']
end
