class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :password, type: String
  field :role, type: String

  validate :validate_content

  def name_valid
    'error_form' if errors[:name].any? || errors[:base].any?
  end

  def email_valid
    'error_form' if errors[:email].any? || errors[:base].any?
  end

  def password_valid
    'error_form' if errors[:password].any? || errors[:base].any?
  end

  private

    def validate_content
      if name.blank? || email.blank? || password.blank?
        errors.add(:base, "You must provide a name, email, and password.")
      else
        if email.present? && !email.match?(URI::MailTo::EMAIL_REGEXP)
          errors.add(:email, "It is invalid, does not have the format")
        end

        if password.present? && password.length < 6
          errors.add(:password, "It is too short (minimum is 6 characters)")
        end
      end
    end
 
end
