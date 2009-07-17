require 'rdoc'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
load    'sinatra-mapping.gemspec'

desc "Generate version for release and tagging."
task :version, [:major, :minor, :patch, :release, :date, :cycle] do |taskspec, version|
  require 'parsedate'
  current      = YAML.load_file(taskspec.name.upcase) || {}
  version_date = Date.new(*ParseDate.parsedate(version[:date] || current[:date].to_s).compact) unless version or current
  newer        = {
    :major   => version[:major].to_i   || current[:major].to_i,
    :minor   => version[:minor].to_i   || current[:minor].to_i,
    :patch   => version[:patch].to_i   || current[:patch].to_i,
    :release => version[:release].to_s.empty? ? nil : version[:release].to_i,
    :date    => version_date           || Date.today,
    :cycle   => version[:cycle]        || current[:cycle]
  }

  newer.merge(current) do |key, new_value, current_value|
    new_value || current_value
  end

  File.open(taskspec.name.upcase, "w") do |version_file|
    version_file << newer.to_yaml
  end
end

Rake::TestTask.new

Rake::GemPackageTask.new(@spec) do |pkg|
  pkg.need_tar_bz2 = true
end

Rake::RDocTask.new("doc") do |rdoc|
  rdoc.title    = "Sinatra::Mapping"
  rdoc.main     = "README"
  rdoc.options  = [ '-SHN', '-f', 'darkfish' ]
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include(
    "CHANGES",
    "LICENSE",
    "README",
    "lib/**/*.rb"
  )
end

