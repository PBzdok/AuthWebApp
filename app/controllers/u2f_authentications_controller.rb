class U2fAuthenticationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    # Fetch existing Registrations from your db
    key_handles = U2fRegistration.all.map(&:key_handle)
    return 'Need to register first' if key_handles.empty?

    # Generate SignRequests
    @app_id = u2f.app_id
    @sign_requests = u2f.authentication_requests(key_handles)
    @challenge = u2f.challenge

    # Store challenge. We need it for the verification step
    session[:challenge] = @challenge

    render 'u2f_authentications/new'
  end

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

    p 'Authenticated!'
  end

  private

  def u2f
    @u2f ||= U2F::U2F.new(request.base_url)
  end
end
