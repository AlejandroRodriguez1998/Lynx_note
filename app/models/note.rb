class Note
    include Mongoid::Document
    include Mongoid::Timestamps
  
    field :title, type: String
    field :content, type: Array

    validate :validate_content, on: :create

    private
    def validate_content
        content_is_present = false

        if content.present?
            content.each do |content_item|
                content_hash = JSON.parse(content_item)
                value = content_hash['value']
                content_is_present = value.blank?

                if content_is_present == false 
                    break
                end
            end

            if content_is_present && title.blank?
                errors.add(:base, "You must provide at least one title or content.")
            end
        else
            if title.blank?
                errors.add(:base, "You must provide at least one title or content.")
            end
        end    
    end
end