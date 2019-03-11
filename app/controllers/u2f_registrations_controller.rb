class U2fRegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    # Generate one for each version of U2F, currently only `U2F_V2`
    @registration_requests = u2f.registration_requests

    # Store challenges. We need them for the verification step
    session[:challenges] = @registration_requests.map(&:challenge)

    # Fetch existing Registrations from your db and generate SignRequests
    key_handles = U2fRegistration.all.map(&:key_handle)
    @sign_requests = u2f.authentication_requests(key_handles)

    @app_id = u2f.app_id

    render 'u2f_registrations/new'
  end

  def create
    p 'u2f creation called'
    response = U2F::RegisterResponse.load_from_json(params[:response])

    reg = begin
      u2f.register!(session[:challenges], response)
    rescue U2F::Error => e
      return "Unable to register: <%= e.class.name %>"
    ensure
      session.delete(:challenges)
    end

    # save a reference to your database
    U2fRegistration.create!(certificate: reg.certificate,
                         key_handle:  reg.key_handle,
                         public_key:  reg.public_key,
                         counter:     reg.counter)

    p 'Registered!'
  end

  private

  def u2f
    @u2f ||= U2F::U2F.new(request.base_url)
  end
end
