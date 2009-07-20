require 'rdoc'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
load    'sinatra-mapping.gemspec'

def current_version(file = "VERSION")
  @current_value ||= YAML.load_file(file) || {}
end

desc "Generate version for release and tagging."
task :version, [:major, :minor, :patch, :release, :date, :cycle] do |taskspec, version|
  require 'parsedate'
  version_date = Date.new(*ParseDate.parsedate(version[:date] || current_version[:date].to_s).compact) unless version or current_version
  newer        = {
    :major   => version[:major].to_i   || current_version[:major].to_i,
    :minor   => version[:minor].to_i   || current_version[:minor].to_i,
    :patch   => version[:patch].to_i   || current_version[:patch].to_i,
    :release => version[:release].to_s.empty? ? nil : version[:release].to_i,
    :date    => version_date           || Date.today,
    :cycle   => version[:cycle]        || current_version[:cycle]
  }

  newer.merge(current_version) do |key, new_value, current_value|
    new_value || current_value
  end

  File.open(taskspec.name.upcase, "w") do |version_file|
    version_file << newer.to_yaml
  end
end

namespace :version do
  desc "Show the current version."
  task :show do
    version = [:major, :minor, :patch, :release].map do |info|
      current_version[info]
    end.compact.join('.')
    puts "#{@spec.name} v#{version} released at #{current_version[:date]} (#{current_version[:cycle]})"
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

