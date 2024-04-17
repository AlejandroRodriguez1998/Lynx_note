class Friendship
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user
  field :friend_id, type: BSON::ObjectId
  field :status, type: String, default: "pending"

end
