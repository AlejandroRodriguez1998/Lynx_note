class Note
    include Mongoid::Document
    include Mongoid::Timestamps
  
    field :title, type: String
    field :content, type: Array

    belongs_to :user

    validate :validate_content

    private
    def validate_content
        content_is_present = false
      
        if content.present?
          content.each do |content_item|
            content_hash = JSON.parse(content_item)
            unless content_hash['value'].blank?
              content_is_present = true
              break
            end
          end
        end
      
        if !content_is_present && title.blank?
          errors.add(:base, "You must provide at least one title or content.")
        end
      end
      
end