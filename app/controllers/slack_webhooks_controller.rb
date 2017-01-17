class SlackWebhooksController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :create

  before_action :ensure_valid_command

  def create
    result = operation.call(create_params)
    if result.success?
      render plain: result.message, status: :created
    else
      Rails.logger.error { "#{result.errors}" }
      render plain: result.errors, status: :unprocessable_entity
    end
  end

  private

  def create_params
    {
      team: team,
      user: user,
      playlist: playlist,
      dj: dj,
      command: params['text']
    }
  end

  def team
    @_team ||= Team.find_or_create_by(slack_id: params['team_id'])
  end

  def player
    @_player ||= Player.find_or_create_by(team_id: team.id)
  end

  def user
    @_user ||= User.find_or_create_by(slack_id: params['user_id'], team_id: team.id) do |u|
      u.name = params['user_name']
    end
  end

  def playlist
    @_playlist ||= Playlist.find_or_create_by(team_id: team.id)
  end

  def dj
    @_dj ||= DJ.new(player, playlist, team.user_rota)
  end

  def operation
    @_operation = commands.detect {|c| c.match?(params['text']) }
  end

  def commands
    [
      PlayVideo,
      FindVideo,
      SkipVideo,
      ShowHelp,
      ShowHistory
    ]
  end

  def ensure_valid_command
    if operation.nil?
      Rails.logger.error { "slack webhook command not valid: #{params[:text]} for team #{params[:team_id]} and user #{params[:user_id]}" }
      head :unprocessable_entity
    end
  end
end
