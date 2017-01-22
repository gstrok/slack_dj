# Return the list of videos
# to be plaed
#

class ListVideos
  include Interactor

  def call
    unplayed = context.dj.playlist.videos.pending.take(10)
    if unplayed.any?
      message = []
      unplayed.each do |video, idx|
        message.push [ video.user.name, video.title ].join(":")
      end
      context.message = message.join "\n"
    else
      context.errors = "No videos in playlist."
      context.fail!
    end
  end

  def self.match?(command)
    command =~ /^list/
  end

end
