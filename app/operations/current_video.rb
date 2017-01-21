# Return the current video playing
#

class CurrentVideo
  include Interactor

  def call
    if context.dj.playing?
      context.message = "Currently playing: #{ context.dj.current_video.title }"
    else
      context.errors = "Nothing playing now."
      context.fail!
    end
  end

  def self.match?(command)
    command =~ /^current/
  end

end
