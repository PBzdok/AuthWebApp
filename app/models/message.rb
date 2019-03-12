class Message < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true

  def sign_content(keypair)
    self.signature = keypair.sign_pss("SHA256",
                                      content,
                                      salt_length: :max,
                                      mgf1_hash: "SHA256")
  end

  def verify_signature(keypair)
    keypair.public_key.verify_pss("SHA256",
                                  signature,
                                  content,
                                  salt_length: :auto,
                                  mgf1_hash: "SHA256")
  end
end
