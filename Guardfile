guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'livereload' do
  watch('lib/prisma/server.rb')
  watch(%r{lib/prisma/server/views/.+\.(erb)})
  watch(%r{lib/prisma/server/public/.+\.(css|js|html)})
end

