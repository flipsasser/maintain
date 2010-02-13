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
    gemspec.name = "oria"
    gemspec.summary = "A Ruby-based, in-memory KVS with one half of the peristence you want"
    gemspec.description = %{
      Oria (oh-rye-uh) is an in-memory, Ruby-based Key-Value store. It's designed to handle moderate amounts of data quickly
      and easily without causing deployment issues or server headaches. It uses EventMachine to provide a networked interface
      to a semi-persistent KVS and asynchronously writes the in-memory data to YAML files.
    }
    gemspec.email = "flip@x451.com"
    gemspec.homepage = "http://github.com/flipsasser/oria"
    gemspec.authors = ["Flip Sasser"]
    gemspec.add_dependency('eventmachine', '>= 0.12.10')
    gemspec.add_dependency('json', '>= 1.2.0')
  end
rescue LoadError
end
