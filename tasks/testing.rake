require "rspec"
require "rspec/core/rake_task"

namespace :spec do
  desc "Run Unit Specs"
  RSpec::Core::RakeTask.new(:units) do |spec|
    spec.pattern = "spec/units/**/*.rb"
  end
  
  desc "Run Integration Specs"
  RSpec::Core::RakeTask.new(:integrations) do |spec|
    spec.pattern = "spec/integrations/**/*.rb"
  end
end

desc "Run unit and integration specs"
task :spec => ["spec:units", "spec:integrations"]

# Echo defines the :default task to run the :test task
task :test => :spec
