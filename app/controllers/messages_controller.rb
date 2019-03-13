class MessagesController < ApplicationController
  before_action :set_message, only: [:edit, :update, :destroy]
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      flash[:success] = "Message created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  # GET /messages/:id/edit
  def edit
    unless multi_factor_enabled
      flash[:error] = "Activate multi factor authentication to sign messages!"
      redirect_to root_url
    end
    initialize_u2f_authentication if current_user.u2f_activated
  end

  # PATCH/PUT /messages/:id
  def update
    if multi_factor_authenticated
      pkey = OpenSSL::PKey::RSA.new(current_user.private_key)
      @message.sign_content(pkey)
      if @message.save
        flash[:info] = "Signature successfully created!"
      else
        flash[:error] = "Signature not created!"
      end
      session.delete(:authentication_token)
      redirect_to root_url
    else
      flash[:error] = "Multi factor authentication failed! Please check profile settings."
      redirect_to 'edit'
    end
  end

  def destroy
    @message.destroy
    flash[:success] = "Message deleted"
    redirect_to request.referrer || root_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, :authenticated, :authentication_token)
  end

  def correct_user
    @message = current_user.messages.find_by(id: params[:id])
    redirect_to root_url if @message.nil?
  end

  def multi_factor_enabled
    current_user.multi_factor_methods.any?
  end

  def multi_factor_authenticated
    message_params[:authentication_token] == session[:authentication_token] && message_params[:authenticated]
  end

  def initialize_u2f_authentication
    # Fetch existing Registrations from your db
    key_handles = U2fRegistration.all.map(&:key_handle)
    return 'Need to register first' if key_handles.empty?

    # Generate SignRequests
    @app_id = u2f.app_id
    @sign_requests = u2f.authentication_requests(key_handles)
    @challenge = u2f.challenge

    # Store challenge. We need it for the verification step
    session[:challenge] = @challenge
  end
end
