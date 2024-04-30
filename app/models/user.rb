require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :password_update

  field :name, type: String
  field :email, type: String
  field :password, type: String
  field :role, type: String

  has_many :collections, dependent: :destroy
  has_many :notes, dependent: :destroy

  has_many :notifications, dependent: :destroy
  
  has_many :initiated_friendships, class_name: 'Friendship', inverse_of: :user, dependent: :destroy
  has_many :received_friendships, class_name: 'Friendship', inverse_of: :friend, dependent: :destroy

  before_destroy :remove_friendships

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
    if unencrypted_password.present? && !bcrypt_password_format?(unencrypted_password)
      super(BCrypt::Password.create(unencrypted_password))
    else
      super(unencrypted_password)
    end
  end

  def bcrypt_password_format?(string)
    /\A\$2[ayb]\$.{56}\z/.match?(string)
  end

  def authenticate(unencrypted_password)
    if BCrypt::Password.new(self.password) == unencrypted_password
      self
    else
      false
    end
  end

  private

    def remove_friendships
      self.initiated_friendships.destroy_all
      Friendship.where(friend_id: self.id).destroy_all
    end

    def validate_content
      if password_update.present?
        if name.blank? || email.blank?
          errors.add(:name, "You must provide a name.") if name.blank?
          errors.add(:email, "You must provide an email.") if email.blank?
        end
      else
        if name.blank? || email.blank? || password.blank?
          errors.add(:name, "You must provide a name.") if name.blank?
          errors.add(:email, "You must provide an email.") if email.blank?
          errors.add(:password, "You must provide a password.") if password.blank?
        end
      end

      if email.present? && !email.match?(URI::MailTo::EMAIL_REGEXP)
        errors.add(:email, "It is invalid, does not have the format")
      end
    end
end
