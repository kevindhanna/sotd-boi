# sotd-boi - *Song of The Day Bot*
This is a Discord Bot for amalgamating Youtube and Spotify links sent to a Discord channel into a nominated Spotify Playlist.

## Installation

- clone this repository
- run `bundle install`
- add the folloing to a .env file:
  * APPURL=_your app url_
  * SPOTIFY_CLIENT_ID=_your spotify client id_
  * SPOTIFY_USER_ID=_your spotify user id_
  * SOTD_PLAYLIST=_the UID of the Song Of The Day Playlist (you'll need edit scope with the above client id)_
  * REDIS_URL=_URL of your Redis instance_
  * DISCORD_TOKEN=_your discord token_
  * DISCORD_CLIENT_ID=_your discord client ID_
- run `bundle exec rackup` locally, or push to Heroku using the included Procfile
- you'll have to grant the app access to your Spotify, account, so navigate to the root `'/'` of your URL and sign in using the provided link. Once signed in the authorization token will be stored in Redis and refreshed when needed.

## How to use

Invite the bot into your channel, then post a song link! It'll detect Spotify and Youtube URLs, and (assuming the song is on spotify and the song name / artist is reasonably easy to find on the page) add the song to the chosen playlist.

