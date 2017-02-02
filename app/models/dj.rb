class DJ
  class PlaylistAlreadyEndedError < StandardError; end
  include Amatch

  attr_reader :player, :playlist, :user_rota

  def initialize(player, playlist, user_rota)
    @player = player
    @playlist = playlist
    @user_rota = user_rota
  end

  # TODO - use whisper and listen for an event
  def new_video_added!
    start! if waiting?
  end

  def check
    if player.playing? && playlist.videos.unplayed.empty?
      player.stop!
    end
  end

  def waiting?
    player.stopped?
  end

  def finished?
    player.stopped? and playlist.all_played?
  end

  def playing?
    player.playing? and player.video.present?
  end

  def current_video
    player.video
  end

  def pending_videos
    Video.pending
  end

  def add_related
    last = playlist.last_played(1).take
    if last.present?
      search = Yt::Collections::Videos.new
      related = search.where( relatedToVideoId: last.youtube_id, order: "viewCount", max_results: 10 )
      if related.present?
        recent = Video.recently_played.pluck(:youtube_id) || []
        filtered = related.select do |r|
          recent.exclude? r.id
        end
        m = JaroWinkler.new(last.title)
        matches = filtered.map do | video |
          { :video_title => video.title, :video_id => video.id, :score => m.match(video.title) }
        end
        best_fit = matches.min_by{|vid| vid[:score]}
        playlist.add_video!(
          title: best_fit[:video_title],
          url: "https://www.youtube.com/watch?v=#{best_fit[:video_id]}"
        )
        return best_fit[:video_title]
      end
    end
  end

  def start!
    if playlist.any_unplayed?
      player.play!(video_selector.start)
    end
  end

  def stop!
    player.stop!
  end

  def switch!
    if playlist.any_unplayed?
      player.switch!(video_selector.next)
    else
      video_title = add_related
      if Video.pending.any?
        player.stop! if player.playing?
        video_title if player.play!( Video.pending.first )
      else
        nil
      end
    end
  end

  def next_up
    video_selector.pending_next
  end

  private

  def video_selector
    @video_selector ||= VideoSelector.new(playlist, user_rota)
  end
end
