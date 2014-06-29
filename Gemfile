if ENV["TAOBAO"]
  source 'http://ruby.taobao.org'
else
  source 'https://rubygems.org'
end

# default gems
gem 'rails', '4.1.0'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'spring', group: :development

gem 'pg' # database
gem 'thin' # server

group :development, :test do
  gem 'pry-rails' # debug
  gem 'factory_girl_rails' # replace 'fixture'
end

group :test do
  gem 'minitest-reporters' # better test output format
  gem 'minitest-spec-rails' # RSpec-like DSL
end

# Heroku
group :production do
  gem 'rails_12factor'
end

ruby "2.1.0"
