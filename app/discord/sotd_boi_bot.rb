require_relative '../spotify/spotify'

module Discord
  module SotdBoiBot
    extend Discordrb::EventContainer, Spotify::SotdBoiSpotify
    
    message(contains: 'https://open.spotify.com/track') do |event|
      if event.channel.name == "song-of-the-day"
        begin      
          uris = []

          # extract spotify URLs from message, convert to spotify track URI and add to URIs array
          URI.extract(event.content.to_s).each do |url|
            
            response = HTTParty.get url
            uri = Nokogiri::HTML(response).at('meta[property="og:url"]')['content'].sub!('https://open.spotify.com/track/','spotify:track:')
            uris.append uri
            end
            
            add_track_to_playlist(uris)

        rescue StandardError => e
          event.respond "Something's broken. Tell Kevin to fix me."
          puts "E: contains_spotify #{Exception} error:"
          puts e
        end
      end
    end

    message(contains: /(https:\/\/).*youtu.*/) do |event|
      if event.channel.name == "song-of-the-day" then
        # gets Youtube video titles to use as search criteria in Spotify
        search_strings = []
        begin
          URI.extract(event.content.to_s).each do |url|
            response = HTTParty.get url
            search_string = Nokogiri::HTML(response).title.scan(/[a-zA-Z0-9\s]/).join("")
            search_string.slice!("  YouTube")

            search_strings.append(search_string)            
          end
          
          search_and_add(search_strings)
        rescue StandardError => e
          event.respond "Something's broken. Tell Kevin to fix me."
          puts "E: contains_youtube #{Exception} error:"
          puts e 
        end
      end
    end

  end
end
