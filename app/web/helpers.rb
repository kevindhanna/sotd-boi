require 'redis'

module Web
    module Helpers

    SPOTIFY_REDIRECT_PATH = '/auth/spotify/callback' 

    # heroku
    # SPOTIFY_REDIRECT_URI = "https://sotd-spotifyintegration.herokuapp.com#{SPOTIFY_REDIRECT_PATH}"

    # #local dev
    require 'dotenv/load'
    SPOTIFY_REDIRECT_URI = "http://localhost:7654#{SPOTIFY_REDIRECT_PATH}"

    REDIS = Redis.new(url: ENV["REDIS_URL"])

    def get_access_token()
      if REDIS.ttl('access_token') < 100
        refresh_access_token
      end
      REDIS.get('access_token')
    end
        
    def get_refresh_token()
      REDIS.get('refresh_token')
    end
        
    def set_tokens(access_token, token_expiry, refresh_token = '')
      REDIS.set('access_token', access_token)
      REDIS.expire('access_token', token_expiry)
      REDIS.set('refresh_token', refresh_token) if refresh_token != ''
    end

    def add_track_to_playlist(track_uris)
      begin
        url = "https://api.spotify.com/v1/playlists/#{ENV['SOTD_PLAYLIST']}/tracks?"
      
        form_data = { 
          'uris' => track_uris
        }
        puts "add_track method form_data = #{form_data}"
      
        headers = {
          'Authorization' => "Bearer #{get_access_token}",
          'Accept:' => 'application/json'
        }
        puts "add_track method headers = #{headers}"
        
        response = HTTParty.post url,
          body: form_data.to_json,
          headers: headers
        puts response
        response.message
      
      rescue Exception => e
        puts e
      end
    end
      
    def refresh_access_token()    
      form_data = {
        'refresh_token' => get_refresh_token,
        'grant_type' => 'refresh_token'
      }
      
      response = HTTParty.post 'https://accounts.spotify.com/api/token',
          query: form_data,
          headers: get_auth_headers
      
      new_hash = JSON.parse(response.to_s).to_h
      set_tokens(new_hash['access_token'], new_hash['expires_in'])  
    end
      
    def get_auth_headers()
      str = ENV['SPOTIFY_CLIENT_ID'] + ':' + ENV['SPOTIFY_CLIENT_SECRET']
      auth_string = Base64.strict_encode64 str
      headers = {
          'Authorization' => "Basic #{auth_string}"
      }
    end
  end
end