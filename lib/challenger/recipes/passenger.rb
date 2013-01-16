set_default :passenger_version, "3.0.19"
namespace :passenger do
  desc "Install Passenger with Nginx"
  task :install, roles: :web do
    run "gem install passenger --version #{passenger_version}"
    run "#{sudo} apt-get install -y libcurl4-openssl-dev"
    run "sudo -u root `rbenv which passenger-install-nginx-module` --auto --auto-download --prefix=/etc/nginx"
  end
end

namespace :deploy do
  task :start do; end
  task :stop do; end

  desc "Restart Application"
  task :restart, roles: :app, except: {no_release: true} do
    run "touch #{current_release}/tmp/restart.txt"
  end
end
