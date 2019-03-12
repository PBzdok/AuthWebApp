class U2fRegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    response = U2F::RegisterResponse.load_from_json(params[:response])
    reg = begin
      u2f.register!(session[:challenges], response)
    rescue U2F::Error => e
      return "Unable to register: <%= e.class.name %>"
    ensure
      session.delete(:challenges)
    end

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
