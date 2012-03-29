require "capistrano"
require "capistrano/cli"
require "bundler/capistrano"

require "challenger/version"

Capistrano::Configuration.instance.load do
  Dir.glob(File.join(File.dirname(__FILE__), '/challenger/recipes/*.rb')).each { |f| load f }
end
