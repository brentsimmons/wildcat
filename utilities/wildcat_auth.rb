require 'argon2'

module WildcatAuth
  def self.verify_password(password, hashed_password)
    return false if password.nil? || password.empty?
    return false if hashed_password.nil? || hashed_password.empty?
    Argon2::Password.verify_password(password, hashed_password)
  end
end
