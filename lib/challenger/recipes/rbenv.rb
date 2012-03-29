set_default :ruby_version, "1.9.3-p125"
set_default :rbenv_bootstrap, "bootstrap-ubuntu-10-04"

namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install curl git-core"
    run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
    bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
fi
BASHRC
    put bashrc, "/tmp/rbenvrc"
    run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
    run "mv ~/.bashrc.tmp ~/.bashrc"
    run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
    run %q{eval "$(rbenv init -)"}
    run "rbenv #{rbenv_bootstrap}"
    run "rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"

    gemrc = <<-GEMRC
--- 
verbose: true
gem: --no-ri --no-rdoc
update_sources: false
sources:
- http://rubygems.org
GEMRC
    put gemrc, "/tmp/gemrc"
    run "mv /tmp/gemrc ~/.gemrc"

    run "gem install bundler"
    run "rbenv rehash"
  end
end
