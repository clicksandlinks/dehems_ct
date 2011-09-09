require 'digest/sha1'

class User < ActiveRecord::Base
  
  apply_simple_captcha 
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :message => "Please enter a username."
  validates_length_of       :login, :minimum => 4, :message => "The username must contain at least 4 characters."
  validates_uniqueness_of   :login, :case_sensitive => false, :message => "This username has already been taken. Please enter a different username."
  validates_presence_of     :password, :if => :password_required?, :message => "Please enter a password."
  validates_presence_of     :password_confirmation, :if => :password_required?, :message => "Please confirm your password."
  validates_length_of       :password, :minimum => 4, :if => :password_required?, :message => "The password must contain at least 4 characters."
  validates_confirmation_of :password, :if => :password_required?, :message => "The password confirmation does not match the password."
  
  before_save :encrypt_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
