source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'devise', '~> 3.0.0'
gem 'thin'
gem 'squeel'
gem 'cancan'
gem 'client_side_validations', :git => 'https://github.com/bcardarella/client_side_validations.git', :branch => '3-2-stable'
gem "nested_form"
gem "mysql2"

group :test, :development do
  gem 'selenium-webdriver'
  gem 'rspec-rails'
	gem 'shoulda-matchers', :require => false
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'guard-rspec'
    #gem 'rb-inotify', '~> 0.9'
	  gem 'rb-fsevent', '~> 0.9', :require => false if RUBY_PLATFORM =~ /darwin/i
	  gem 'growl'
  gem 'launchy'
	gem 'database_cleaner'
	gem 'simplecov', :require => false
end

gem 'holidays', '~> 1.0.5'
gem 'will_paginate', '~> 3.0'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
  gem 'debugger'

# Awesome Print
  gem "awesome_print", "~> 1.2.0"
