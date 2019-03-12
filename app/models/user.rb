class User < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :u2f_registrations, dependent: :destroy
  has_secure_password

  attr_accessor :remember_token, :activation_token, :reset_token, :totp

  before_create :create_activation_digest, :create_otp_secret, :create_rsa_keypair
  before_save   :downcase_email

  validates :name, presence: true,
                   length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, presence: true,
                       length: { minimum: 6 },
                       allow_nil: true

  # Returns a random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  # Creates and assigns the totp object and returns the qr code
  def create_totp
    self.totp = ROTP::TOTP.new(otp_secret)
    RQRCode::QRCode.new(totp.provisioning_uri('AuthWebApp'), size: 8, level: :h)
  end

  # Verify TOTP value with temporal totp object
  def verify_totp(password)
    ROTP::TOTP.new(otp_secret).verify(password)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    Message.where("user_id = ?", id)
  end

  def multi_factor_methods
    auth_methods = { totp: totp_activated, u2f: u2f_activated}
    auth_methods.select { |_, v| v == true }
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  # Creates and assigns the secret for otp authentication. Is not securely saved!
  def create_otp_secret
    self.otp_secret = ROTP::Base32.random_base32
  end

  def create_rsa_keypair
    pkey = OpenSSL::PKey::RSA.new(2048)
    self.public_key = pkey.public_key.to_pem
    self.private_key = pkey.to_pem
  end

end
