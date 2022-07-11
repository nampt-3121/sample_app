class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy

  before_save :downcase_email
  before_create :create_activation_digest

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

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def activate
    update_columns(
      activated: true,
      activated_at: Time.zone.now,
      activation_digest: nil
    )
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.user.expired_reset_pw_time.hours.ago
  end

  def feed
    microposts
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
