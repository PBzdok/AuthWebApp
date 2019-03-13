class U2fAuthenticationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    response = U2F::SignResponse.load_from_json(params[:response])

    registration = U2fRegistration.find_by_key_handle(response.key_handle)
    return 'Need to register first' unless registration

    begin
      u2f.authenticate!(session[:challenge],
                        response,
                        Base64.decode64(registration.public_key),
                        registration.counter)
    rescue U2F::Error => e
      return "Unable to authenticate: <%= e.class.name %>"
    ensure
      session.delete(:challenge)
    end

    registration.update(counter: response.counter)
    sign_message
    redirect_to root_url
  end

  private

  def sign_message
    pkey = OpenSSL::PKey::RSA.new(current_user.private_key)
    message = Message.find(params[:message_id])
    message.sign_content(pkey)
    message.save
  end
end
