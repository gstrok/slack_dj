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
    team.users[1] or current_user
  end

  def all
    team.users
  end

  private

  attr_reader :team
end
