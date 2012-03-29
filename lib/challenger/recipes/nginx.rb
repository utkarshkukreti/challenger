set_default(:nginx_server_name) { Capistrano::CLI.ui.ask("Server Hostname (separate multiple hosts with space)") }
namespace :nginx do
  desc "Configures nginx (after Passenger has installed Nginx)"
  task :install do
    template "nginx", "/tmp/nginx"
    run "#{sudo} mv /tmp/nginx /etc/init.d/nginx"
    run "#{sudo} chmod +x /etc/init.d/nginx"
    run "#{sudo} update-rc.d -f nginx defaults"
    template "nginx.conf.erb", "/tmp/nginx.conf"
    run "#{sudo} mv /tmp/nginx.conf /etc/nginx/conf/nginx.conf"
    run "#{sudo} mkdir /etc/nginx/conf/sites-enabled/"
  end

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx_passenger.erb", "/tmp/nginx.conf"
    run "#{sudo} mv /tmp/nginx.conf /etc/nginx/conf/sites-enabled/#{application}"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end
