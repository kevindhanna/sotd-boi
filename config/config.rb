configatron.app.env                 = ENV["APP_ENV"]     || "development"
configatron.app.disable_web         = ENV["DISABLE_WEB"] || false
configatron.app.url                 = ENV['APP_URL']

# Bot Opts
configatron.discord.token           = ENV["DISCORD_TOKEN"]
configatron.discord.client_id       = ENV["DISCORD_CLIENT_ID"]
configatron.discord.bot_prefix      = ENV["DISCORD_BOT_PREFIX"]
configatron.discord.bot_mode        = configatron.app.disable_web ? nil : :async

# Spotify Opts
configatron.redis.url               = ENV["REDIS_URL"]
configatron.spotify.playlist_uri    = ENV['SOTD_PLAYLIST']
configatron.spotify.client_secret   = ENV['SPOTIFY_CLIENT_SECRET']
configatron.spotify.client_id       = ENV['SPOTIFY_CLIENT_ID']
configatron.spotify.redirect_path   = '/auth/spotify/callback'
configatron.spotify.redirect.uri    = "#{configatron.app.url}#{configatron.spotify.redirect_path}"
