# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  user_name       :string(255)      not null
#  password_digest :string(255)      not null
#  session_token   :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base
  has_many :cats
  has_many :cat_rental_requests

  validates :user_name, :password_digest, :session_token, presence: true
  validates :user_name, :session_token, :password_digest, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }

  after_initialize :ensure_session_token

  attr_reader :password

  def create_session_token
    SecureRandom::urlsafe_base64
  end

  def ensure_session_token
    self.session_token ||= create_session_token
  end

  def reset_session_token!
    self.session_token = create_session_token
    self.save!
  end

  def self.find_by_credentials(user_name, password)
    user = User.find_by(user_name: user_name)

    if user && user.is_password?(password)
      return user
    end

    nil
  end

  def is_password?(password)
    BCrypt::Password.new(password_digest).is_password?(password)
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end
end
