# Takes the query in given command and searches
# youtube for first 10 results. Stores query results
# in redis under key for specific users and returns
# the list to the user
#
require "redis"

class FindVideo
  include Interactor

  # Expects:
  # team
  # user
  # dj
  # playlist
  # command e.g. "find Michael Jackson Thriller"
  #
  def call
    videos = search_youtube
    if videos.any?
      r = Redis.new
      user_key = context.user.search_key
      # delete current users video list
      r.del user_key
      message = []
      videos.each.with_index  do |video, idx|
        # push videos to list
        video_obj = { id: video.id, title: video.title }
        r.rpush user_key, video_obj.to_json
        message.push [ idx, video.title ].join(" - ")
      end
      r.expire user_key, 60
      message.push "NOTICE: This message will be automatically destroyed in 60 seconds"
      context.message = message.join "\n"
    else
      context.errors = "Sorry but couldn't find any vides for #{query}."
      context.fail!
    end
  end

  def self.match?(command)
    command =~ /^find/
  end

  private


  def search_youtube
     search = Yt::Collections::Videos.new
     videos = search.where(q: query, order: "viewCount", max_results: 10 )
     videos
  end

  def query
    query = context.command.gsub(/^find/, "").strip
  end
end
