require "fileutils"
class ResultsGenerator
  attr_reader :fixtures_file, :buld_name
  def initialize(options={})
    [:fixtures_file].each do |option|
      raise(ArgumentError, "options[:#{option}] is blank") if options[option].nil?
    end
    raise(ArgumentError, "Please provide Build Name in BUILD_NAME=") if ENV['BUILD_NAME'].nil?
    @fixtures_file = options[:fixtures_file]
    @buld_name = ENV['BUILD_NAME']
  end
  
  def generate!
    commands = YAML.load_file(File.join(File.dirname(__FILE__), 'results_generator.yml'))
    video_file = File.join(File.dirname(__FILE__), 'files/boat.avi')
    
    fixtures = YAML.load_file(self.fixtures_file)
    fixtures[self.buld_name] = {}
    
    tmp_dir = Dir.mktmpdir 

    commands.each do |name, command|  
      output_file = File.join(tmp_dir, "tmp#{rand(999999)}.mp4")
      command.gsub!(/\$input_file\$/, video_file)
      command.gsub!(/\$output_file\$/,  output_file)
      command.chomp!
      
      puts "Executing: #{command}"
      output = `#{command} 2>&1`
      fixtures[self.buld_name][name] = output
      f = File.open(self.fixtures_file, 'w')
      YAML::dump(fixtures, f)
      f.close
    end
    FileUtils.rm_rf tmp_dir
    puts "\n\n\n***************"
    puts "Check spec/fixtures/ffmpeg_results.yml file"
    puts "Fix indetation and add junk to end of unexpected_results section\n"
  end
end