require File.dirname(__FILE__) + '/../spec_helper'

module RVideo
  module Tools
  describe 'RVideo Tools' do

    let(:options){ {
      :input_file => spec_file("kites.mp4"),
      :output_file => "bar",
      :width => "320", :height => "240"
    } }
    let(:simple_avi) {"ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"}
    let(:ffmpeg){ RVideo::Tools::Ffmpeg.new(simple_avi, options) }

    describe Ffmpeg do
      
      it "initializes with valid arguments" do
        ffmpeg.class.should == Ffmpeg
      end
      
      it "has the correct tool_command" do
        ffmpeg.tool_command.should == 'ffmpeg'
      end
      
      it "calls parse_result on execute, with a ffmpeg result string" do
        ffmpeg.should_receive(:parse_result).once.with /\Affmpeg version/
        ffmpeg.execute
      end
      
      it "executes execute_with_progress" do
        ffmpeg.execute_with_progress
      end
      
      it "mixin AbstractTool" do
        Ffmpeg.included_modules.include?(AbstractTool::InstanceMethods).should be_true
      end
      
      it "sets supported options successfully" do
        ffmpeg.options[:resolution].should == options[:resolution]
        ffmpeg.options[:input_file].should == options[:input_file]
        ffmpeg.options[:output_file].should == options[:output_file]
      end
      
    end
    
    describe Ffmpeg, " magic variables" do
      let(:options) {{
        :input_file  => spec_file("boat.avi"),
        :output_file => "test"
      }}

      before do
        Ffmpeg.video_bit_rate_parameter = Ffmpeg::DEFAULT_VIDEO_BIT_RATE_PARAMETER
      end
      
      it 'supports copying the originsl :fps' do
        options.merge! :fps => "copy"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame $fps$ -vf 'scale=320:240' -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 15.10 -vf 'scale=320:240' -y '#{options[:output_file]}'"
      end
      
      it 'supports :width and :height options to build :resolution' do
        options.merge! :width => "640", :height => "360"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=640:360' -y '#{options[:output_file]}'"
      end
      
      it 'supports calculated :height' do
        options.merge! :width => "640"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=640:480' -y '#{options[:output_file]}'"
      end
      
      it 'supports calculated :width' do
        options.merge! :height => "360"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=480:360' -y '#{options[:output_file]}'"
      end
      
      it 'supports :width and :height options to build :resolution_and_padding' do
        options.merge! :width => "160", :height => "120"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution_and_padding$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=160:120' -y '#{options[:output_file]}'"
      end
      
      it 'supports :width and :height options to build :resolution_and_padding with negatif ratio' do
        options.merge! :width => "120", :height => "160"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution_and_padding$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=120:90,pad=120:160:0:35' -y '#{options[:output_file]}'"
      end
      
      it 'supports :width and :height options to build :resolution_keep_aspect_ratio' do
        options.merge! :width => "120", :height => "160"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $resolution_keep_aspect_ratio$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -vf 'scale=120:90' -y '#{options[:output_file]}'"
      end
      
      it 'supports :width and :height options to build :resolution_and_padding with negatif ratio' do
        options.merge! :width => "160", :height => "100"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution_and_padding$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=134:100' -y '#{options[:output_file]}'"
      end
      
      it 'supports odd value on width or height' do
        mock_original_file = mock(:original, :width => 640, :height => 480, :rotated? => false)
        RVideo::Inspector.stub!(:new).and_return(mock_original_file)

        options.merge! :width => "620", :height => "349"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution_and_padding$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=464:348' -y '#{options[:output_file]}'"
      end

      it 'supports nil width or height' do
        mock_original_file = mock(:original, :width => 0, :height => 0, :rotated? => false)
        RVideo::Inspector.stub!(:new).and_return(mock_original_file)

        options.merge! :width => "620", :height => "349"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution_and_padding$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=620:348' -y '#{options[:output_file]}'"
      end

      it 'supports odd value in the padding' do
        mock_original_file = mock(:original, :width => 320, :height => 240, :rotated? => false)
        RVideo::Inspector.stub!(:new).and_return(mock_original_file)

        options.merge! :width => "225", :height => "222"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution_and_padding$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=224:168,pad=224:222:0:27' -y '#{options[:output_file]}'"
      end
      
      it 'supports odd value in the padding' do
        mock_original_file = mock(:original, :width => 1920, :height => 1080, :rotated? => false)
        RVideo::Inspector.stub!(:new).and_return(mock_original_file)

        options.merge! :width => "854", :height => "480"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution_and_padding$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -vf 'scale=854:480' -y '#{options[:output_file]}'"
      end

      it 'supports :video_bit_rate' do
        options.merge! :video_bit_rate => 666
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_bit_rate$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 666k -y '#{options[:output_file]}'"
      end

      it "supports :video_bit_rate and configurable command flag" do
        Ffmpeg.video_bit_rate_parameter = "v"
        options.merge! :video_bit_rate => 666
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_bit_rate$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -v 666k -y '#{options[:output_file]}'"
      end
      
      ###

      it "supports :video_bit_rate_tolerance" do
        options.merge! :video_bit_rate_tolerance => 666
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_bit_rate_tolerance$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -bt 666k -y '#{options[:output_file]}'"
      end
      
      ###
      
      it "supports :video_bit_rate_max and :video_bit_rate_min" do
        options.merge! :video_bit_rate => 666, :video_bit_rate_min => 666, :video_bit_rate_max => 666
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_bit_rate$ $video_bit_rate_min$ $video_bit_rate_max$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 666k -minrate 666k -maxrate 666k -y '#{options[:output_file]}'"
      end

      it "supports :deinterlace => true" do
        options.merge! :deinterlace => true
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $deinterlace$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -deinterlace -y '#{options[:output_file]}'"
      end

      it "handles :deinterlace => false correct" do
        options.merge! :deinterlace => false
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $deinterlace$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}'  -y '#{options[:output_file]}'"
      end
      
      ###
      
      # TODO for these video quality specs we might want to show that the expected
      # bitrate is calculated based on dimensions and framerate so you can better 
      # understand it without going to the source.
      
      it "supports :video_quality => 'low'" do
        options.merge! :video_quality => "low"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_quality$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 96k -crf 30 -me zero -subq 1 -refs 1 -threads auto -y '#{options[:output_file]}'"
      end
      
      it "supports :video_quality => 'medium'" do
        options.merge! :video_quality => "medium"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_quality$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 128k -crf 22 -flags +loop -cmp +sad -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me hex -subq 3 -trellis 1 -refs 2 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -y '#{options[:output_file]}'"
      end
      
      it "supports :video_quality => 'high'" do
        options.merge! :video_quality => "high"
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_quality$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 322k -crf 18 -flags +loop -cmp +sad -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me full -subq 6 -trellis 1 -refs 3 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -y '#{options[:output_file]}'"
      end
      
      ###
      
      it "supports :video_quality => 'low' with arbitrary :video_bit_rate" do
        options.merge! :video_quality => "low", :video_bit_rate => 666
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_quality$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 666k -crf 30 -me zero -subq 1 -refs 1 -threads auto -y '#{options[:output_file]}'"
      end
      
      it "supports :video_quality => 'medium' with arbitrary :video_bit_rate" do
        options.merge! :video_quality => "medium", :video_bit_rate => 666
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_quality$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 666k -crf 22 -flags +loop -cmp +sad -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me hex -subq 3 -trellis 1 -refs 2 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -y '#{options[:output_file]}'"
      end
      
      it "supports :video_quality => 'high' with arbitrary :video_bit_rate" do
        options.merge! :video_quality => "high", :video_bit_rate => 666
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ $video_quality$ -y $output_file$", options)
        ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -b 666k -crf 18 -flags +loop -cmp +sad -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me full -subq 6 -trellis 1 -refs 3 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -y '#{options[:output_file]}'"
      end
      
      # These appear unsupported..
      # 
      # it 'should support passthrough height' do
      #   options = {:input_file => spec_file("kites.mp4"), :output_file => "bar", :width => "640"}
      #   command = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"
      #   ffmpeg = Ffmpeg.new(command, options)
      #   ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s 640x720 -y 'bar'"        
      # end
      # 
      # it 'should support passthrough width' do
      #   options = {:input_file => spec_file("kites.mp4"), :output_file => "bar", :height => "360"}
      #   command = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"
      #   ffmpeg = Ffmpeg.new(command, options)
      #   ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s 1280x360 -y 'bar'"        
      # end
    end
    
    describe Ffmpeg, " when parsing a result" do
      load_fixture(:ffmpeg_results).each do |build, results|
        let(:iphone_result){ ffmpeg_result(build, :iphone) }
        let(:android_result){ ffmpeg_result(build, :android) }
        let(:simple_h264_result){ ffmpeg_result(build, :simple_h264) }

        it "creates correct result metadata" do
          ffmpeg.send(:parse_result, iphone_result).should be_true
          ffmpeg.frame.should == '136'
          ffmpeg.output_fps.should == '0'
          ffmpeg.q.should == '39.0'
          ffmpeg.size.should == '196kB'
          ffmpeg.time.should == '00:00:03.32'
          ffmpeg.output_bitrate.should == '484.0kbits/s'
          ffmpeg.video_size.should == "764kB"
          ffmpeg.audio_size.should == "89kB"
          ffmpeg.header_size.should == "0kB"
          ffmpeg.overhead.should == "1.134934%"
          ffmpeg.psnr.should be_nil
        end
      
        it "creates correct result metadata (2)" do
          ffmpeg.send(:parse_result, android_result).should be_true
          ffmpeg.frame.should == '275'
          ffmpeg.output_fps.should == '0'
          ffmpeg.q.should == '9.4'
          ffmpeg.size.should == '660kB'
          ffmpeg.time.should == '00:00:10.92'
          ffmpeg.output_bitrate.should == '494.7kbits/s'
          ffmpeg.video_size.should == "812kB"
          ffmpeg.audio_size.should == "89kB"
          ffmpeg.header_size.should == "0kB"
          ffmpeg.overhead.should == "1.077030%"
          ffmpeg.psnr.should be_nil
        end
        
        it "creates correct result metadata (3)" do
          ffmpeg.send(:parse_result, simple_h264_result).should be_true
          ffmpeg.frame.should == '63'
          ffmpeg.output_fps.should == '0'
          ffmpeg.q.should == '30.0'
          ffmpeg.size.should == '145kB'
          ffmpeg.time.should == '00:00:01.98'
          ffmpeg.output_bitrate.should == '599.8kbits/s'
          ffmpeg.video_size.should == "909kB"
          ffmpeg.audio_size.should == "74kB"
          ffmpeg.header_size.should == "0kB"
          ffmpeg.overhead.should == "0.989353%"
          ffmpeg.psnr.should be_nil
        end
                
        it "calculates PSNR if it is turned on" do
          ffmpeg.send(:parse_result, iphone_result.gsub("Lsize=","LPSNR=Y:33.85 U:37.61 V:37.46 *:34.77 size=")).should be_true
          ffmpeg.psnr.should == "Y:33.85 U:37.61 V:37.46 *:34.77"
        end
      end
    end
    
    describe Ffmpeg, "result parsing should raise an exception" do
      def parsing_result(build, result_fixture_key)
        lambda { ffmpeg.send(:parse_result, ffmpeg_result(build, result_fixture_key)) }
      end

      load_fixture(:ffmpeg_results).each do |build, results|

        it "when a param is missing a value" do
          parsing_result(build, :param_missing_value).
            should raise_error(TranscoderError::InvalidCommand, /Expected .+ for .+ but found: .+/)
        end
      
        it "when codec not supported" do
          parsing_result(build, :amr_nb_not_supported).
            should raise_error(TranscoderError::InvalidFile, "Codec amr_nb not supported by this build of ffmpeg")
        end
      
        it "when not passed a command" do
          parsing_result(build, :missing_command).
            should raise_error(TranscoderError::InvalidCommand, "must pass a command to ffmpeg")
        end
      
        it "when given a broken command" do
          parsing_result(build, :broken_command).
            should raise_error(TranscoderError::InvalidCommand, /Unable to find a suitable output format for/)
        end
      
        it "when the output file has no streams" do
          parsing_result(build, :output_has_no_streams).
            should raise_error(TranscoderError, /Output file does not contain.*stream/)
        end
      
        it "when given a missing input file" do
          parsing_result(build, :missing_input_file).
            should raise_error(TranscoderError::InvalidFile, /No such file or directory/)
        end
      
        it "when given a file it can't handle"
      
        it "when cancelled halfway through"
    
        it "when receiving unexpected results" do
          parsing_result(build, :unexpected_results).
            should raise_error(TranscoderError::UnexpectedResult, 'foo - bar')
        end
      
        it "with an unsupported codec" do
          pending
        
          parsing_result(build, :unsupported_codec).
            should raise_error(TranscoderError::InvalidFile, /samr/)
        end
      
        it "when a stream cannot be written" do
          parsing_result(build, :unwritable_stream).
            should raise_error(TranscoderError, /incorrect codec parameters/)
        end
      end
    end
  end
  end
end
