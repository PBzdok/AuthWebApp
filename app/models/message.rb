class Message < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true

  def sign_content(keypair)
    signature_ascii_8bit = keypair.sign_pss("SHA256",
                                            content,
                                            salt_length: :max,
                                            mgf1_hash: "SHA256")
    self.signature = Base64.encode64(signature_ascii_8bit).encode('utf-8')
  end

  def verify_signature(keypair)
    decoded_signature = Base64.decode64(signature.encode('ascii-8bit'))
    keypair.public_key.verify_pss("SHA256",
                                  decoded_signature,
                                  content,
                                  salt_length: :auto,
                                  mgf1_hash: "SHA256")
  end
end
