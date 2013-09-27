require 'rake'

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
    gemspec.files = Dir["{lib}/**/*", "CHANGES.md", "LICENSE", "README.markdown"]
    gemspec.test_files = Dir["{spec}/**/*"]
    gemspec.required_ruby_version = ">= 1.9"
  end
rescue LoadError
end
