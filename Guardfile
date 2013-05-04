guard 'minitest' do
  watch(%r|^spec/(.*)_spec\.rb|)
  watch(%r|^lib/([^/]+)\.rb|) do |m|
    "spec/#{m[1]}_spec.rb"
  end
  watch(%r|^spec/spec_helper\.rb|) { "spec" }
end
