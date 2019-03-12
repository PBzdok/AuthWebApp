require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @message = @user.messages.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    assert @message.valid?
  end

  test "user id should be present" do
    @message.user_id = nil
    assert_not @message.valid?
  end

  test "content should be present" do
    @message.content = "   "
    assert_not @message.valid?
  end

  test "create signature" do
    pkey = OpenSSL::PKey::RSA.new(2048)
    @message.sign_content(pkey)
    assert_not_nil @message.signature
  end

  test "verify signature" do
    pkey = OpenSSL::PKey::RSA.new(2048)
    @message.sign_content(pkey)
    assert @message.verify_signature(pkey)
  end

  test "verify signature with wrong keypair" do
    pkey = OpenSSL::PKey::RSA.new(2048)
    @message.sign_content(pkey)
    other_pkey = OpenSSL::PKey::RSA.new(2048)
    assert_not @message.verify_signature(other_pkey)
  end
end
