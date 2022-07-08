class User < ApplicationRecord
  attr_accessor :remember_token

  VALID_EMAIL_REGEX = Settings.regex.email

  validates :name, presence: true,
            length: {maximum: Settings.digits.length_50}

  validates :email, presence: true,
            length: {maximum: Settings.digits.length_255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: true

  validates :password, presence: true,
            length: {minimum: Settings.digits.length_6},
            allow_nil: true

  before_save :downcase_email

  scope :sort_name, ->{order :name}

  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.blank?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private

  def downcase_email
    email.downcase!
  end
end
