class ExpiryLink < ActiveRecord::Base
	#Time in SECS to after which the reset link will expire.
	RESET_TIMEOUT = 60*60*3
	LINK_LENGTH = 16
	def self.generate_link(user)
		link = 	SecureRandom.urlsafe_base64(LINK_LENGTH)
		if(ExpiryLink.where(uid:user.id).empty?)
			ExpiryLink.create(email:user.email,uid:user.id,link:link)
		else
			e = ExpiryLink.where(uid:user.id).first
			e.update(link:link)
		end
		link
	end
	def is_valid?
		if (Time.now - updated_at) >= RESET_TIMEOUT
			destroy
			false
		else
			true
		end
	end
end
