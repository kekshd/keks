# encoding: utf-8

class User < ActiveRecord::Base
  STUDY_PATHS = [:bsc_physics, :bsc_maths, :edu_degree]
  VALID_EMAIL_REGEX = /\A[\w+\-._]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password


  attr_accessible :nick
  attr_accessible :mail

  attr_accessible :study_path
  enumerate :study_path

  attr_accessible :password, :password_confirmation

  attr_protected :admin

  validates :nick, presence: true, uniqueness: true
  validates :mail, allow_blank: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 4 }
  validates :password_confirmation, presence: true
  validates_inclusion_of :study_path, in: StudyPath

  # http://stackoverflow.com/questions/7919584/rails-3-1-create-one-user-in-console-with-secure-password

  before_save { mail.downcase! }
  before_save :create_remember_token

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
