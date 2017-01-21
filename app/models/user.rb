class User < ApplicationRecord
  has_many :videos
  belongs_to :team, optional: true
  acts_as_list scope: :team

  validates :slack_id, presence: true

  def search_key
    [ "search", self.id  ].join(":")
  end

end
