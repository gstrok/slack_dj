# Return the list of videos
# to be plaed
#

class NextVideo
  include Interactor

  def call
    next_video = context.dj.next_up
    if next_video
      context.message = ["Next:", next_video.title].join(" ")
    else
      context.errors = "No videos in playlist."
      context.fail!
    end
  end

  def self.match?(command)
    command =~ /^next/
  end

end
