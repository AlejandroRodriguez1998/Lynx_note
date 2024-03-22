class Note < ApplicationRecord
    has_many_attached :images
    serialize :list, Array, coder: YAML
    validate :at_least_one_field_present, on: :create

    private
        def at_least_one_field_present
            if text.blank? && list.reject { |item| item.blank? }.blank? && images.blank?
                errors.add(:base, "You must provide at least one text, a list or an image.")
            end
        end
end