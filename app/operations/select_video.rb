# Takes the video idx and selects
# it from the users search list
#
require "redis"

class SelectVideo
  include Interactor

  def call
    r = Redis.new(:port => ENV.fetch('REDIS_PORT') || 6379 )
    user_key = context.user.search_key
    video_data = r.lindex user_key, idx
    if video_data.present?
      video = JSON.parse( video_data )
      context.playlist.add_video!(
        title: video["title"],
        url: "https://www.youtube.com/watch?v=#{video['id']}",
        user: context.user
      )
      context.dj.new_video_added!
      context.message = "#{video['title']} was added to the playlist."
    else
      context.errors = "Could not find video at idx #{ idx }. Check your list with list command"
      context.fail!
    end
  end

  def self.match?(command)
    command =~ /^select/
  end

  def idx
    idx = context.command.gsub(/^select/, "").strip
  end

end
