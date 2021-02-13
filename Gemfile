# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

plugin 'bundler-download'

gem 'glimmer-dsl-swt', '~> 4.17.0'

# Enable Chromium Browser Glimmer Custom Widget gem if needed (e.g. Linux needs it to support HTML5 Video), and use `browser(:chromium)` in GUI.
gem 'glimmer-cw-browser-chromium', '~> 4.17.0'

group :development do
  gem 'rspec', '~> 3.5.0'
  gem 'juwelier', '2.4.9'
  gem 'warbler', '2.0.5'
  gem 'simplecov', '>= 0'
end
