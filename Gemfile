source "http://rubygems.org"
gemspec

group :development, :test do
  gem "rake"
  gem "flvtool2"
  gem "ruby-debug", :platforms => :mri_18
  gem "ruby-debug19", :require => "ruby-debug", :platforms => :mri_19 if RUBY_VERSION < "1.9.3"
end