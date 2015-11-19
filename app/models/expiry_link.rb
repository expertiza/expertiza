class ExpiryLink < ActiveRecord::Base
	def self.get_email(link)
		e = ExpiryLink.where(link:link).first
		if e.nil?
			nil
		else
			e.email
		end
	end
	def self.generate_link(email)
		link = 	SecureRandom.urlsafe_base64(16)
		if(ExpiryLink.where(email:email).empty?)
			ExpiryLink.create(email:email,link:link)
		else
			e = ExpiryLink.where(email:email).first
			e.update(link:link)
		end
		link
	end
	def is_valid?
		if (Time.now - updated_at) >= 60*60
			destroy
			false
		else
			true
		end
	end
end
