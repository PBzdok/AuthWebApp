class U2fRegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    response = U2F::RegisterResponse.load_from_json(params[:response])
    registration = begin
      u2f.register!(session[:challenges], response)
    rescue U2F::Error => e
      return "Unable to register: <%= e.class.name %>"
    ensure
      session.delete(:challenges)
    end

    @u2f_registration = current_user.u2f_registrations.build(certificate: registration.certificate,
                                                             key_handle: registration.key_handle,
                                                             public_key: registration.public_key,
                                                             counter: registration.counter)
    if @u2f_registration.save
      p 'Registered!'
    else
      p 'Error on saving!'
    end
  end
end
