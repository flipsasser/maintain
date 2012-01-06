require 'rake'

task :default => :spec

begin
  require 'spec/rake/spectask'

  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
  end

  desc "Run all examples with RCov"
  Spec::Rake::SpecTask.new('spec:rcov') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,gem']
  end
rescue LoadError
  puts "Could not load Rspec. To run tests, use `gem install rspec`"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "maintain"
    gemspec.summary = "A Ruby state machine that lets your code do the driving"
    gemspec.description = %{
      Maintain is a simple state machine mixin for Ruby objects. It supports comparisons, bitmasks,
      and hooks that really work. It can be used for multiple attributes and will always do its best to
      stay out of your way and let your code drive the machine, and not vice versa.
    }
    gemspec.email = "flip@x451.com"
    gemspec.homepage = "http://github.com/flipsasser/maintain"
    gemspec.authors = ["Flip Sasser"]
  end
rescue LoadError
end
