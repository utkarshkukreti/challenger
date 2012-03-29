def template(from, to)
  erb = File.read(File.expand_path("../../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

set_default :user, "deployer"
set_default(:deploy_to) { "/var/apps/#{application}" }
set_default :deploy_via, :remote_cache
set_default :use_sudo, false

set_default :scm, "git"
set_default :branch, "master"

default_run_options[:pty] = true
default_run_options[:shell] = "/bin/bash"
ssh_options[:forward_agent] = true

namespace :deploy do
  desc "Setup deployer user with root account\nSet ENV variable PUBLIC_KEY=path/to/file to use public key other than ~/.ssh/id_rsa.pub"
  task :root do
    set :user, "root"
    run "useradd deployer --home /var/apps --create-home --shell /bin/bash"
    run 'if [[ $(cat /etc/sudoers) != *deployer* ]]; then sed -i "/root.*ALL=(ALL) ALL/ a\\\\deployer ALL\\=\\(ALL\\) NOPASSWD\\: ALL" /etc/sudoers; fi'
    run "mkdir -p /var/apps/.ssh"
    public_key = File.read(ENV["PUBLIC_KEY"] || File.expand_path("~/.ssh/id_rsa.pub"))
    put public_key, "/tmp/public_key"
    run "cat /tmp/public_key >> /var/apps/.ssh/authorized_keys"
    run "rm /tmp/public_key"
  end

  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties"
  end
  after "deploy:install", "postgresql:install"
  after "deploy:install", "nodejs:install"
  after "deploy:install", "rbenv:install"
  after "deploy:install", "passenger:install"
  after "deploy:install", "nginx:install"
end
