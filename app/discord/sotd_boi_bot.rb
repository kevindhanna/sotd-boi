module Discord
  module SotdBoiBot
    extend Discordrb::EventContainer
    
    message(contains: 'https://open.spotify.com/track') do |event|
      if event.channel.name == "song-of-the-day"
        begin      
          URI.extract(event.content.to_s).each do |url|
            response = HTTParty.get url
            uri = Nokogiri::HTML(response).at('meta[property="og:url"]')['content'].sub!('https://open.spotify.com/track/','spotify:track:')
            form_data = {
              'uris' => uri
            }
            
            response = HTTParty.post ENV['SPOTIFY_INTEGRATION_URL'],
              body: form_data
    
            puts response
          end
        rescue Exception => e
          event.respond "Something's broken. Tell Kevin to fix me."
          puts e
        end
      end
    end

    message(contains: /(https:\/\/).*youtu.*/) do |event|
      if event.channel.name == "song-of-the-day" then
        begin
          URI.extract(event.content.to_s).each do |url|
            response = HTTParty.get url
            search_string = Nokogiri::HTML(response).title.scan(/[a-zA-Z0-9\s]/).join("")
            puts search_string
            search_string.slice!("  YouTube")
            form_data = { 'search_string' => search_string }

            response = HTTParty.post ENV['SPOTIFY_SEARCH_URL'],
              body: form_data

            puts response

          end
        rescue Exception => e
          event.respond "Something's broken. Tell Kevin to fix me."
          puts e 
        end
      end
    end

  end
end
