require 'sinatra'
require 'sinatra/cookies'
require 'base64'
require 'uri'
require_relative '../spotify/spotify'
require 'dotenv/load' if configatron.app.env = 'development'

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
    
    helpers Sinatra::Cookies, Spotify::SotdBoiSpotify

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
        "redirect_uri=#{URI.encode(configatron.spotify.redirect.uri)}&state=#{state}" 
    end
    
    get configatron.spotify.redirect_path do
      code = params[:code]
      state = params[:state]
      storedState = cookies[:stateKey]
      if state.nil? || state != storedState
        redirect '/#error=state_mismatch'
      else
        cookies[:stateKey] = nil

        request_auth_tokens(code)
      end
      redirect to('/')
    end
  end
end
