# Skips the currently playign video
#

require 'uri'
require 'cgi'

class SkipVideo
  include Interactor

  # Expects:
  # team
  # user
  # dj
  # playlist
  # command string
  #
  def call
    if context.dj.player.stopped?
      # add code
      if context.dj.add_related(context.user)
        context.message = "Autoplaying.."
        context.dj.new_video_added!
      else
        context.errors = "Failed getting related video."
        context.fail!
      end
    else
      context.message = "That video was skipped!"
      context.dj.switch!
    end
  end

  def self.match?(command)
    command =~ /^skip/
  end
end
