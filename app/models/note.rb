class Note < ApplicationRecord
    has_many_attached :images
    validate :at_least_one_field_present

    private
        def at_least_one_field_present
            if text.blank? && list.blank? && images.blank?
                errors.add(:base, "You must provide at least one text, a list or an image.")
            end
        end
end