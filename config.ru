# Main entrypoint. Things loaded here are available EVERYWHERE.
unless ENV['RACK_ENV'] == 'production'
  require 'dotenv/load'
end

require 'redis'
require 'rubygems'
require 'bundler'
require 'httparty'
Bundler.require(:default, ENV["APP_ENV"] || "development")

require_all 'config/config.rb', 'config/discord.rb'

REDIS = Redis.new(url: configatron.redis.url)

$bot.run :async

require_all 'config/web.rb'
run Web::Base
$stdout.sync = true
