ruby '2.2.3', :engine => 'jruby', :engine_version => '9.0.5.0'
source 'https://rubygems.org'

gem 'rails', '4.2.4'
gem 'turbolinks'
gem 'jquery-rails'
gem 'puma'
gem 'figaro'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :jruby]
gem 'uglifier', '>= 1.3.0'
gem 'maestrano-connector-rails'

gem 'constantcontact'
gem 'countries'

group :test do
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'timecop'
end

group :production, :uat do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'rails_12factor'
end

group :test, :develpment do
  gem 'activerecord-jdbcsqlite3-adapter'
end

