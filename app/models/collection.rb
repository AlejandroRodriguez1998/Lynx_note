class Collection
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :user, type: String
  field :notes, type: Array, default: []

  validate :validate_title

  def name_valid
    'error_form' if errors[:base].any? 
  end

  private
  def validate_title
      if name.blank?
        errors.add(:base, "You must provide a title.")
      end
    end

end
