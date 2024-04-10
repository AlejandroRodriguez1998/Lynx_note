require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :password, type: String
  field :role, type: String

  validate :validate_content

  def name_valid
    'error_form' if errors[:name].any? 
  end

  def email_valid
    'error_form' if errors[:email].any?
  end

  def password_valid
    'error_form' if errors[:password].any?
  end

  #Sobreescribimos el metodo de asignacion de la password
  def password=(unencrypted_password)
    if unencrypted_password.present?
      super(BCrypt::Password.create(unencrypted_password))
    else
      super(unencrypted_password)
    end
  end

  def authenticate(unencrypted_password)
    if BCrypt::Password.new(self.password) == unencrypted_password
      self
    else
      false
    end
  end

  private

    def validate_content
      if name.blank? || email.blank? || password.blank?
        errors.add(:name, "You must provide a name.") if name.blank?
        errors.add(:email, "You must provide an email.") if email.blank?
        errors.add(:password, "You must provide a password.") if password.blank?
      end

      if email.present? && !email.match?(URI::MailTo::EMAIL_REGEXP)
        errors.add(:email, "It is invalid, does not have the format")
      end

    end
end
