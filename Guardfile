guard :rspec, cmd: 'bundle exec rspec' do
  watch('spec/spec_helper.rb')                        { 'spec' }
  watch('config/routes.rb')                           { 'spec/routing' }
  watch('app/controllers/application_controller.rb')  { 'spec/controllers' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  do |m|
    ["spec/controllers/#{m[1]}_controller_spec.rb", "spec/routing/#{m[1]}_routing_spec.rb",
     "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"]
  end
  watch(%r{^app/controllers/(.+)/(.+)_(controller)\.rb$}) do |m|
    ["spec/controllers/#{m[1]}/#{m[2]}_controller_spec.rb", "spec/routing/#{m[2]}_routing_spec.rb", "spec/#{m[3]}s/#{m[1]}/#{m[2]}_#{m[3]}_spec.rb", "spec/acceptance/#{m[2]}_spec.rb"]
  end
end