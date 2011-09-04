require "rspec"
require "rspec/core/rake_task"
require File.join(File.dirname(__FILE__), '../spec/results_generator')

namespace :spec do
  desc "Run Unit Specs"
  RSpec::Core::RakeTask.new(:units) do |spec|
    spec.pattern = "spec/units/**/*.rb"
  end
  
  desc "Run Integration Specs"
  RSpec::Core::RakeTask.new(:integrations) do |spec|
    spec.pattern = "spec/integrations/**/*.rb"
  end
  
  desc "Generate results by runing local ffmpeg and put them to ffmpeg_results.yml"
  task :generate_ffmpeg_results do
    rg = ResultsGenerator.new(:fixtures_file => File.join(File.dirname(__FILE__), '../spec/fixtures/ffmpeg_results.yml'))
    rg.generate!
  end
end

desc "Run unit and integration specs"
task :spec => ["spec:units", "spec:integrations"]

# Echo defines the :default task to run the :test task
task :test => :spec
