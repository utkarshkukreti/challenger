require "capistrano"
require "challenger/version"

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).each { |f| load f }
