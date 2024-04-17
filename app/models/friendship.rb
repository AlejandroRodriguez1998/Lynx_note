class Friendship
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :friend, class_name: 'User', inverse_of: nil

  field :status, type: String, default: "pending"

end
