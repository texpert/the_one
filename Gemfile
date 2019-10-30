# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'httpx'
gem 'rubyzip'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw] unless ENV['RM_INFO']
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance'
end

group :test do
  #gem 'factory_bot'
  #gem 'faker'
  #gem 'rspec'
  #gem 'shoulda-matchers'
end
