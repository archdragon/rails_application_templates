## Accept relative paths
def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

## Gemfile

remove_file 'Gemfile'
run 'touch Gemfile'

add_source 'https://rubygems.org'

gem 'rails', '4.2.1'

gem 'slim'
gem 'bower-rails', '~> 0.10.0'

gem 'pg'

gem 'devise'
gem 'pundit'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'compass-rails'

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'dotenv-rails'
  gem 'rubocop'
  gem 'overcommit'
  gem 'spring'
end


after_bundle do
  ## DB Setup
  puts '-- DB setup'
  remove_file 'config/database.yml'
  copy_file 'includes/database.template', 'config/database.yml'
  gsub_file 'config/database.yml', /{APP_NAME}/, "#{app_name}"

  run 'bundle exec rake db:create'

  ## Scaffolding users
  puts '-- Scaffolding users'

  generate :scaffold, 'user name:string'

  route "root to: 'pages#index'"

  run 'bundle exec rake db:migrate'

  # Install bower
  run 'rails g bower_rails:initialize'
  remove_file 'Bowerfile'
  copy_file 'includes/Bowerfile.template', 'Bowerfile'
  run 'rake bower:install'

  puts '-- Preparing git'

  git :init
  run "git config user.name 'Przemyslaw Krowinski'"
  run "git config user.email 'hello@krowinski.com'"
  git add: '.'
  git commit: %Q{ -m 'Initial commit' }
  run 'bundle exec overcommit --install'

  run 'rails s'
end

