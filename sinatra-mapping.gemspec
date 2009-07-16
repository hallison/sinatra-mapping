@version  = YAML.load_file("VERSION")
@info     = YAML.load_file("INFO")
@manifest = `git ls-files`.split.sort.reject{ |out| out =~ /^\./ || out =~ /^doc/ }
@spec     = Gem::Specification.new do |gemspec|
  gemspec.platform = Gem::Platform::RUBY
  gemspec.version  = [ @version[:major], @version[:minor], @version[:patch], @version[:release] ].compact.join('.')
  gemspec.date     = @version[:date]

  @info.each do |info, value|
    gemspec.send("#{info}=", value) if gemspec.respond_to? "#{info}="
  end

  @info[:dependencies].each do |name, version|
    gemspec.add_dependency name, version
  end

  gemspec.require_paths = %w[lib]
  gemspec.files = @manifest
  gemspec.test_files = gemspec.files.select{ |path| path =~ /^test\/test_.*.rb/ }

  gemspec.has_rdoc = true
  gemspec.extra_rdoc_files = %w[README LICENSE]

  gemspec.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Sinatra - Mapping", "--main", "README"]
  gemspec.rubyforge_project = gemspec.name
  gemspec.rubygems_version = "1.3.3"
end if @version || @info # Gem::Specification

