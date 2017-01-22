class DJ
  class PlaylistAlreadyEndedError < StandardError; end

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

  def waiting?
    player.stopped? and playlist.any_unplayed?
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

  def add_related(user)
    last = playlist.last_played(1).take
    if last.present?
      search = Yt::Collections::Videos.new
      related = search.where( relatedToVideoId: last.youtube_id ).first
      if related.present?
        playlist.add_video!(
          title: related.title,
          url: "https://www.youtube.com/watch?v=#{related.id}",
          user: user
        )
        return related.title
      end
    end
  end

  def start!
    if playlist.any_unplayed?
      player.play!(video_selector.start)
    else
      raise PlaylistAlreadyEndedError, "Playlist #{playlist.id} already ended"
    end
  end

  def stop!
    player.stop!
  end

  def switch!
    if playlist.any_unplayed?
      player.switch!(video_selector.next)
    else
      user_rota.advance_to_next_turn
      video_title = add_related(user_rota.current_user)
      video_title if player.stop! and player.play!( Video.next_for(user_rota.current_user) )
    end
  end

  private

  def video_selector
    @video_selector ||= VideoSelector.new(playlist, user_rota)
  end
end
