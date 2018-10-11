# Expertiza Security module
#
# Author : Philip Musyoki
# Email: pmusyok@ncsu.edu
#
# SUMMARY
# The modules provides security encryption features used in Experiza. It provides an abstration to row-level
# encryption and allow transparent encryption and decryption of records in models that include the module.
#
# REMARKS
# There are different approaches to encryption:
#
# The simplest implementation is by using a static key and salt. In this case, the keys should be stored in
# enviroment variables EXPERTIZA_KEY_ENCRYPTION_KEY and EXPERTIZA_SALT.
#
# A more complex method is to use a unique key and salt for each record. If this method is encrypted, the model
# should have both salt and data_encryption_key fields defined. The module generates an encryption key for each
# record, and then encrypts it with the salt and the key encryption key and stores it with the record. During
# decryption, the store data encryption key is decrypted with the salt and the key encryption key, and then the
# encrypted field is decrypted.
#
# EXPERTIZA_KEY_ENCRYPTION_KEY environment variable is still required to encrypt the data encryption key.
#
# EXPERTIZA_SALT is used when there is no row level salt. If there is a salt field defined, a salt will be
# generated for every new record.
#
# In summary, whatever implementation is selected should be changed if any record isn encyrpted, since this will
# render the encrypted fields unrecoverable.
#
# Encrypted fields should be stored as strings in the database, since the output of the encryption function will
# be a string, regardless of the data type being encrypted.
#
# USAGE
# Require the module, then include it in the model that you want to encypt. The attr_encrypted callbacks will add
# encryption to the field, and the type_cast_method option will call the method give on the decrypted string to
# convert it to the desired type -- like from string to an integer. It is optional.
#
# EXAMPLE
# class User < ApplicationRecord
#   require 'expertiza_security'
#   include ExpertizaSecurity
#
#   attr_encrypted :name, type_cast_method: :to_s
#   attr_encrypted :telephone, type_cast_method: :to_s
#   attr_encrypted :age, type_cast_method: :to_i
#   ...
# end
#
# FINAL COMMENTS
# The salt and data encryption key can be changed transparently for each record and the module will decrypt and
# encrypt the data with the new salt and data encryption key.
#
# The key encryption key stored in the enviroment variable should never be changed when there are records that rely
# on it for decryption. A key rotation function can be added to this module to change the key encryption key. The
# data will need to be decrypted with the old key encryption key and decrypted with the new one. Not a trivial
# exercise. But if each record has a data encryption key, then oly the fields needs re-encryption when the key
# encryption key is changed.
#
# END OF COMMENTS

module ExpertizaSecurity
  extend ActiveSupport::Concern

  included do
    cattr_accessor :is_encrypted, :encrypted_attributes, :encryption_options, :is_hashed, :hashed_attributes

    before_save :encrypt
    after_initialize :decrypt
    after_save :decrypt

    self.is_encrypted = false
    self.encrypted_attributes = []
    self.encryption_options = {}
    self.is_hashed = false
    self.hashed_attributes = []

    [:is_encrypted, :is_hashed].each do |method_name|
      self.define_method "#{method_name}?" do
        self.send(method_name)
      end
    end

    def self.attr_encrypted(attr_encrypted, options = {})
      self.is_encrypted = true
      self.encrypted_attributes.push attr_encrypted unless self.encrypted_attributes.include? attr_encrypted
      self.encryption_options[attr_encrypted] = options
    end

    def self.attr_hashed(attr_hashed)
      self.is_hashed = true
      self.hashed_attributes.push attr_hashed unless self.hashed_attributes.include? attr_hashed
    end

    private

    def decrypt
      if self.is_encrypted? && !self.new_record?
        salt = self.has_attribute?(:salt) ? self.salt ||= KeyManagement.salt : KeyManagement.salt

        if self.has_attribute? :data_encryption_key
          if self.data_encryption_key
            crypt = Crypt.new(KeyManagement.key_encryption_key, salt)
            data_encryption_key = crypt.decrypt(self.data_encryption_key)
          else
            data_encryption_key = KeyManagement.key_encryption_key
          end
        else
          data_encryption_key = KeyManagement.key_encryption_key
        end

        if !data_encryption_key.nil? && self.encrypted_attributes.respond_to?(:each)
          crypt = Crypt.new(data_encryption_key, salt)

          self.encrypted_attributes.uniq.each do |encrypted_attribute|
            attributes = {}

            if self.has_attribute?(encrypted_attribute)
              options = self.encryption_options[encrypted_attribute]
              plain_text = crypt.decrypt(self.read_attribute(encrypted_attribute))
              plain_text = plain_text.send(options[:type_cast_method]) if options.key?(:type_cast_method)
              attributes[encrypted_attribute] = plain_text if plain_text
            end

            self.assign_attributes(attributes) if !attributes.empty?
          end
        end
      end
    end

    def encrypt
      if self.new_record?
        self.salt = KeyManagement.generate_salt if self.has_attribute?(:salt)
      end

      salt = self.has_attribute?(:salt) ? self.salt ||= KeyManagement.salt : KeyManagement.salt
      crypt = Crypt.new(KeyManagement.key_encryption_key, salt)

      if self.new_record?
        if self.has_attribute? :data_encryption_key
          data_encryption_key = KeyManagement.generate_data_encryption_key
          self.data_encryption_key = crypt.encrypt(data_encryption_key)
        else
          data_encryption_key = KeyManagement.key_encryption_key
        end
      end

      if self.is_hashed? && !self.salt.nil?
        if self.hashed_attributes.respond_to?(:each)
          self.hashed_attributes.each do |hashed_attribute|
            self.send("#{hashed_attribute}=", Crypt.hash_message(self.read_attribute(hashed_attribute), salt)) if self.has_attribute?(hashed_attribute) && self.send("#{hashed_attribute}_changed?")
          end
        end
      end

      if self.is_encrypted?
        unless self.new_record?
          if self.has_attribute? :salt
            if self.salt_changed? && !self.data_encryption_key_changed?
              last_salt = self.changes[:salt][0]
              last_crypt = Crypt.new(KeyManagement.key_encryption_key, last_salt)
              data_encryption_key = last_crypt.decrypt(self.data_encryption_key)
              self.data_encryption_key = crypt.encrypt(data_encryption_key )
            end
          end

          if self.has_attribute? :data_encryption_key
            if self.data_encryption_key_changed?
              data_encryption_key = self.data_encryption_key
              self.data_encryption_key = crypt.encrypt(self.data_encryption_key)
            else
              data_encryption_key = self.data_encryption_key ? crypt.decrypt(self.data_encryption_key) : KeyManagement.key_encryption_key
            end
          else
            data_encryption_key = KeyManagement.key_encryption_key
          end
        end

        if self.encrypted_attributes.respond_to?(:each)
          crypt = Crypt.new(data_encryption_key, salt)

          self.encrypted_attributes.each do |encrypted_attribute|
            self.send("#{encrypted_attribute}=", crypt .encrypt(self.read_attribute(encrypted_attribute))) if self.has_attribute?(encrypted_attribute) && self.send("#{encrypted_attribute}")
          end
        end
      end
    end
  end

  class Crypt
    def initialize(key, salt)
      @crypt = ActiveSupport::MessageEncryptor.new(ActiveSupport::KeyGenerator.new(key).generate_key(salt, 32))
    end

    def encrypt(message)
      @crypt.encrypt_and_sign(message)
    end

    def decrypt(message)
      @crypt.decrypt_and_verify(message)
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage
      message
    end

    class << self
      def hash_message(message, salt)
        sha256 = OpenSSL::Digest::SHA256.new
        sha256.hexdigest("#{salt}-#{message}")
      end

      def verify_hashed_message(hashed_message, message, salt)
        hash_message message, salt == hashed_message
      end
    end
  end

  class KeyManagement
    class << self
      def key_encryption_key
        ENV['EXPERTIZA_KEY_ENCRYPTION_KEY']
      end

      def salt
        ENV['EXPERTIZA_SALT']
      end

      def generate_uuid
        SecureRandom.uuid
      end

      def generate_salt
        SecureRandom.hex(32)
      end

      def generate_data_encryption_key
        SecureRandom.hex(64).to_s
      end
    end
  end
end