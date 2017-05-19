
require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/scm/git"
require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/puma"

install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Workers

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
