# encoding: utf-8

class User < ActiveRecord::Base
  STUDY_PATHS = [:bsc_physics, :bsc_maths, :edu_degree]
  VALID_EMAIL_REGEX = /\A[\w+\-._]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password


  attr_protected :nick
  validates :nick, presence: true, uniqueness: true

  attr_accessible :mail
  validates :mail, allow_blank: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  attr_accessible :study_path
  enumerate :study_path
  validates_inclusion_of :study_path, in: StudyPath

  attr_accessible :password, :password_confirmation
  validates :password, length: { minimum: 4 }, :if => :should_validate_password?
  validates :password_confirmation, presence: true, :if => :should_validate_password?

  attr_protected :admin
  attr_protected :enrollment_keys






  # http://stackoverflow.com/questions/7919584/rails-3-1-create-one-user-in-console-with-secure-password

  before_save { mail.downcase! }
  before_save :create_remember_token

  attr_accessor :updating_password

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

  def should_validate_password?
    updating_password || new_record?
  end
end
