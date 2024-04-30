class Notification
    include Mongoid::Document
    include Mongoid::Timestamps

    field :message, type: String
    field :notification_type, type: String

    belongs_to :user
end