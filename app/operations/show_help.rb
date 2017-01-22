# Returns a string formatted list
# of all the commands you can use
# on slack.


class ShowHelp
  include Interactor
  include Rails.application.routes.url_helpers

  # Expects:
  # team
  # user
  # dj
  # playlist
  # command e.g. "help"
  #
  def call
    context.message = help_message
  end

  def self.match?(command)
    command =~ /^help/
  end

  def help_message
<<-DOC
Watch your teams videos here...
#{team_url}

Play a video via its youtube url
/dj play http://youtube.com....

Find videos by artist and name
/dj find george michael last christmas

Add the video from search results to the playlist
/dj select 2

Display videos from last serach(valid only for 60 seconds)
/dj mylist

Skip the currently playing video
/dj skip

Display videos in playlist
/dj list

Display previously played videos
/dj history
DOC
  end

  def team_url
    player_url(host: ENV.fetch('APP_DOMAIN'))
  end
end
