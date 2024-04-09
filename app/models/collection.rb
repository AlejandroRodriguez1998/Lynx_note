class Collection
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :user, type: String
  field :notes, type: Array, default: []

end
