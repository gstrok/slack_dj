class UserRota
  def initialize(team)
    @team = team
  end

  def advance_to_next_turn
    team.users.first.move_to_bottom
  end

  def current_user
    team.users.first
  end

  def next_in_line
    users = team.users.to_a
    first = users.shift()
    users.push( first )
    user = nil
    users.each do |u|
      video = Video.next_for( u )
      if video.present?
        user = u
        break
      end
    end
    user
  end

  def all
    team.users
  end

  private

  attr_reader :team
end
