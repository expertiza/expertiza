require "digest"
require 'digest/sha1'
require 'openssl'
require 'base64'

module DigitalSig
   
  def self.gen_digital_signature(data_string_1, data_string_2, private_key, certificate)
    
     # check for private key
     if private_key.nil? || private_key.length < 800  
       return nil
     end 
     
     # check that user has a certificate 
     if certificate.nil? || certificate.length < 500
       return nil
     end

     # digest data strings
     hash_data_1 = Digest::SHA1.digest(data_string_1) # assign name
     time_now = Time.now.strftime("%Y-%m-%d %H:%M:%S")  
     sign = hash_data_1 + data_string_2 + time_now  # userid
     input_data = Digest::SHA1.digest(sign) 
          
     # create digital sig of input data using private_key
     pkey = OpenSSL::PKey::RSA.new(private_key)       
     cipher_text = Base64.encode64(pkey.private_encrypt(input_data))
      
     # get public key from the certificate         
     cert = OpenSSL::X509::Certificate.new(certificate)
     pub_key = cert.public_key 

     # decrypt using the public key
     clear_text = pub_key.public_decrypt(Base64.decode64(cipher_text))
       
     # if verified return digital signature else nil  
     (input_data == clear_text)? cipher_text : nil
      
  rescue
    return nil
  end

end
