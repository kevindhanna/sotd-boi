require 'sinatra'
require 'sinatra/cookies'
require 'base64'
require 'uri'

module Web
  class Base < Sinatra::Base
    configure :production, :development do
      enable :logging
      set    :public_folder, 'app/web/public'
      set    :views,         'app/web/views'
      set    :erb, escape_html: true,
                   layout_options: {views: 'app/views/layouts'}
      set :port, 7654
      enable :sessions
    end

    helpers Web::Helpers, Sinatra::Cookies
    # use Web::Hooks
    # use Web::Dashboard


    get '/' do
      haml :index
    end

    not_found do
      erb :not_found
    end

    get '/auth/spotify' do
      state = SecureRandom.hex
      cookies[:stateKey] = state
    
      scope = 'playlist-modify-public playlist-modify-private'
      redirect 'https://accounts.spotify.com/authorize?' +
        "response_type=code&" +
        "client_id=#{ENV['SPOTIFY_CLIENT_ID']}&" +
        "scope=#{scope}&" +
        "redirect_uri=#{URI.encode(SPOTIFY_REDIRECT_URI)}&state=#{state}" 
    end
    
    get SPOTIFY_REDIRECT_PATH do
      begin
        code = params[:code]
        state = params[:state]
        storedState = cookies[:stateKey]
        if state.nil? || state != storedState
          redirect '/#error=state_mismatch'
        else
          cookies[:stateKey] = nil
    
          form_data = {
            'code' => code,
            'redirect_uri' => SPOTIFY_REDIRECT_URI,
            'grant_type' => 'authorization_code'
          }
    
          response = HTTParty.post 'https://accounts.spotify.com/api/token',
              query: form_data,
              headers: get_auth_headers
          
          user_hash = JSON.parse(response.to_s).to_h
          set_tokens(user_hash['access_token'], user_hash['expires_in'], user_hash['refresh_token'])
    
        end
      rescue Exception => e
        puts e
      end
      redirect to('/')
    end
    
    post '/addtrack' do
      uris = [params[:uris]]
      puts "/addtrack uris = #{uris}"
      add_track_to_playlist(uris)
    end
    
    post '/search_and_add' do
      search_string = params[:search_string]
      begin
        
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
        add_track_to_playlist([track_uri])
    
      rescue Exception => e
        puts e
      end
    end
  end
end
