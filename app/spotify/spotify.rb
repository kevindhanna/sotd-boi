module Spotify
  module SotdBoiSpotify

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

    def request_auth_tokens(redirect_code)
      # uses spotify client ID and secret to request initial 0Auth headers
      begin
        form_data = {
          'code' => redirect_code,
          'redirect_uri' => configatron.spotify.redirect.uri,
          'grant_type' => 'authorization_code'
        }
  
        response = HTTParty.post 'https://accounts.spotify.com/api/token',
            query: form_data,
            headers: get_auth_headers
        
        user_hash = JSON.parse(response.to_s).to_h
        set_tokens(user_hash['access_token'], user_hash['expires_in'], user_hash['refresh_token'])
      rescue StandardError => e
        puts "E: request_auth_tokens #{Exception} error:"
        puts e
      end
    end

    def add_track_to_playlist(track_uris)
      # adds each track uri in array to nominated playlist
      begin
        url = "https://api.spotify.com/v1/playlists/#{configatron.spotify.playlist_uri}/tracks?"
      
        form_data = { 
          'uris' => track_uris
        }
      
        headers = {
          'Authorization' => "Bearer #{get_access_token}",
          'Accept:' => 'application/json'
        }
        
        response = HTTParty.post url,
          body: form_data.to_json,
          headers: headers
        
        puts response
      
      rescue StandardError => e
        puts "E: add_track_to_playlist #{exception} error:"
        puts e
      end
    end

    def search_and_add(search_strings)
      # sends each search string to spotify and append to URIs array
      begin
        uris = []
        search_strings.each do |search_string|
          headers = {
            'Authorization' => "Bearer #{get_access_token}",
          }
      
          form_data = { 
            'q' => search_string,
            'type' => 'track'
          }
      
          response = HTTParty.get'https://api.spotify.com/v1/search',
            query: form_data,
            headers: headers

          
          track_uri = JSON.parse(response.to_s)["tracks"]["items"].first["uri"]
          uris.append(track_uri)
        end

        add_track_to_playlist(uris)
    
      rescue StandardError => e
        puts "E: search_and_add #{Exception} error:"
        puts e
      end
    end
      
    def refresh_access_token()
      # uses stored refresh token to request a new access token from Spotify web API
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
      str = configatron.spotify.client_id + ':' + configatron.spotify.client_secret
      auth_string = Base64.strict_encode64 str
      headers = {
          'Authorization' => "Basic #{auth_string}"
      }
    end
  end
end