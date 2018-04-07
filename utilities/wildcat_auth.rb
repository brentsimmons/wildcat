require 'argon2'

Module WildcatAuth

	def self.verify_password(password, hashed_password)
		if password.nil? || password.empty? then return false end
		if hashed_password.nil? || hashed_password.empty? then return false end
		Argon2::Password.verify_password(password, hashed_password)
	end
end
