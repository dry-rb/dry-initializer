guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/(spec_helper|support)}) { "spec" }
  watch(%r{^lib/.+}) { "spec" }
end
