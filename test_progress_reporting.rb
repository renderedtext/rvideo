# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
require "rubygems"
require "bundler/setup"

require 'lib/rvideo'

transcoder = RVideo::Transcoder.new

recipe = "ffmpeg -i $input_file$ -ar 22050 -ab 64 -f flv -y $output_file$"
recipe += "\nflvtool2 -U $output_file$"
begin
  transcoder.execute(recipe, {:input_file => "/tmp/test.flv",
    :output_file => "tmp/output.flv", :progress => true}) do |command, progress|
    puts "#{command}: #{progress}%"
  end
rescue RVideo::TranscoderError => e
  puts "Unable to transcode file: #{e.class} - #{e.message}"
end