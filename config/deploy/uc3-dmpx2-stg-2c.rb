set :application, 'DMPTool'
set :repo_url, 'https://github.com/CDLUC3/dmptool.git'

set :server_host, ENV["SERVER_HOST"] || 'uc3-dmpx2-stg-2c.cdlib.org'
server fetch(:server_host), user: 'dmp', roles: %w{web app db}

set :deploy_to, '/dmp/apps/dmp'
set :share_to, 'dmp/apps/dmp/shared'

# Define the location of the private configuration repo
set :config_branch, 'uc3-dmpx2-stg'

set :rails_env, 'stage'

namespace :deploy do
  #after :deploy, 'swagger:build'
end
=begin
namespace :swagger do
  desc 'Build the Swagger API docs'
  task :build do
    on roles(:app), wait: 1 do
      execute "cd #{release_path} && bundle exec rake rswag"
    end
  end
end
=end