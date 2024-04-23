class Friendship
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String, default: "pending"

  belongs_to :user, inverse_of: :initiated_friendships
  belongs_to :friend, class_name: 'User', inverse_of: :received_friendships

  scope :accepted, -> { where(status: 'accepted') }
  scope :pending, -> { where(status: 'pending') }

end
  
  
