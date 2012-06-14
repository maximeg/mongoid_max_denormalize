guard(
  'rspec',
  :all_after_pass => false,
  :cli => "--drb --fail-fast --tty --format documentation --colour") do

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb spec/cases" }
  watch('spec/spec_helper.rb')  { "spec" }
end

