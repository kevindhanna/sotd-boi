require_all 'app/discord/**/*.rb'
require 'discordrb'

$bot = Discordrb::Bot.new(
  token:       configatron.discord.token,
  client_id:   configatron.discord.client_id
)

# Load all discord containers.
Dir['./app/discord/**/*.rb'].each do |file|
  container = file.gsub("./app/","").gsub(".rb","").camelize
  $bot.include! container.constantize
end
