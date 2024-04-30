class Friendship
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String, default: "pending"

  belongs_to :user, inverse_of: :initiated_friendships
  belongs_to :friend, class_name: 'User', inverse_of: :received_friendships

  scope :accepted, -> { where(status: 'accepted') }
  scope :pending, -> { where(status: 'pending') }

  after_destroy :cleanup_sharings

  private
    def cleanup_sharings
      Sharing.where(:shared_with.in => [self.friend.id]).each do |sharing|
        sharing.pull(shared_with: self.friend_id)
      end
      Sharing.where(:shared_with.in => [self.user.id]).each do |sharing|
        sharing.pull(shared_with: self.user_id)
      end
    end

end