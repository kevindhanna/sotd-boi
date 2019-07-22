# Main entrypoint. Things loaded here are available EVERYWHERE.
require 'redis'
require 'rubygems'
require 'bundler'
require 'dotenv/load'
require 'httparty'
Bundler.require(:default, ENV["APP_ENV"] || "development")

require_all 'config/config.rb', 'config/discord.rb'

REDIS = Redis.new(url: configatron.redis.url)

$bot.run configatron.discord.bot_mode

unless configatron.app.disable_web
  require_all 'config/web.rb'
  Web::Base.run!
  $stdout.sync = true
end
