require File.dirname(__FILE__) + '/../spec_helper'

module RVideo
  module Tools
  
    describe MpegtsH264 do
      before do
        setup_mpegts_h264_spec
      end
      
      it "should initialize with valid arguments" do
        @mpegts_h264.class.should == MpegtsH264
      end
      
      it "should have the correct tool_command" do
        @mpegts_h264.tool_command.should == 'MpegtsH264'
      end
            
      it "should mixin AbstractTool" do
        QtFaststart.included_modules.include?(AbstractTool::InstanceMethods).should be_true
      end
      
      it "should set supported options successfully" do
        @mpegts_h264.options[:output_files].should == @options[:output_files]
        @mpegts_h264.options[:input_file].should == @options[:input_file]
        @mpegts_h264.options[:index_file].should == @options[:index_file]
      end
    end
  end
end

def setup_mpegts_h264_spec
  @options = {:input_file => "foo.mp4", :output_files => "foo-???.ts", :index_file => 'testa.m3u8'}
  @command = "MpegtsH264 -i $input_file$ -o $output_files$ -I $input_file$"
  @mpegts_h264 = RVideo::Tools::MpegtsH264.new(@command, @options)
end