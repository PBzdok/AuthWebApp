require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @message = messages(:one)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Message.count' do
      post messages_url, params: { message: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Message.count' do
      delete message_url(@message)
    end
    assert_redirected_to login_url
  end
end
