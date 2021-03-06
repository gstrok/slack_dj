class Player < ApplicationRecord

  class PlayerAlreadyPlayingError < StandardError; end
  class PlayerAlreadyStoppedError < StandardError; end

  STATUSES = ['stopped', 'playing']

  validates :status, inclusion: { in: STATUSES }

  belongs_to :video, optional: true

  def eject_video
    update_attributes(video_id: nil)
  end

  def stopped?
    status == "stopped"
  end

  def set_video(video)
    update_attributes(video_id: video.id) and video.played! if video
  end

  def playing?
    status == "playing"
  end

  def play!(video)
    Player.transaction do
      if stopped? and set_video(video) and update_attribute(:status, "playing")
        Cable.broadcast 'player_channel', nextVideo: video
        true
      else
        raise PlayerAlreadyPlayingError, "Player #{self.id} is already playing video id:#{video.id}."
      end
    end
  end

  def stop!
    Player.transaction do
      if playing? and eject_video and update_attribute(:status, "stopped")
        Cable.broadcast 'player_channel', stop: true
        true
      else
        raise PlayerAlreadyStoppedError, "Player #{self.id} is already stopped."
      end
    end
  end

  def switch!(video)
    stop! if playing?
    if play!(video)
      video.title
    end
  end
end
