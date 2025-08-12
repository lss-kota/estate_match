source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 8.0.0'
gem 'mysql2', '~> 0.5'
gem 'puma', '>= 5.0'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder'
gem 'bootsnap', require: false
gem 'image_processing', '~> 1.2'
gem 'sprockets-rails'

group :development, :test do
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'brakeman', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner-active_record'
end

gem 'tailwindcss-rails'

# Authentication
gem 'devise'
gem 'rqrcode'
gem 'rotp'

gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]
