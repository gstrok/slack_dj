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
      related = context.dj.add_related
      if related
        context.dj.switch!
        context.message = [ "Autoplaying.. #{ related }" ].join(" ")
      else
        context.errors = "Failed getting related video."
        context.fail!
      end
    else
      current_video = context.dj.current_video
      context.message = "Skipping!"
      next_title = context.dj.switch!
      if next_title
        context.message = [ context.message, "Playing #{ next_title }" ].join(" ")
      end
    end
  end

  def self.match?(command)
    command =~ /^skip/
  end
end
