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
      # set :port, 7654
      enable :sessions
    end

    helpers Sinatra::Cookies
    SPOTIFY_REDIRECT_PATH = '/auth/spotify/callback' 
    # heroku
    SPOTIFY_REDIRECT_URI = "https://sotd-spotifyintegration.herokuapp.com#{SPOTIFY_REDIRECT_PATH}"
    # #local dev
    # require 'dotenv/load'
    # SPOTIFY_REDIRECT_URI = "http://localhost:7654#{SPOTIFY_REDIRECT_PATH}"

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
  end
end
