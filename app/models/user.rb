class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :nick, :presence => true, :uniqueness => true

  attr_accessible :mail, :uniqueness => true, :allow_nil => true

  # http://stackoverflow.com/questions/7919584/rails-3-1-create-one-user-in-console-with-secure-password

  before_save :create_remember_token

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
