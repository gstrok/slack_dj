# Return the list of videos
# for last query
#
require "redis"

class ListMyVideos
  include Interactor

  def call
    r = context.redis_instance
    user_key = context.user.search_key
    videos = r.lrange user_key, 0, -1
    if videos.any?
      message = []
      videos.each.with_index do |video_data,idx|
        video = JSON.parse video_data
        message.push [ idx, video["title"] ].join( " - " )
      end
      context.message = message.join "\n"
    else
      context.errors = "List expired."
      context.fail!
    end
  end

  def self.match?(command)
    command =~ /^mylist/
  end

end
