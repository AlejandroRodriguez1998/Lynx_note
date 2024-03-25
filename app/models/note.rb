class Note
    include Mongoid::Document
    include Mongoid::Timestamps
  
    field :title, type: String
    field :content, type: Array
    
end