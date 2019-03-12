class MessagesController < ApplicationController
  before_action :set_message, only: [:edit, :update, :destroy]
  before_action :logged_in_user, only: [:create, :destroy, :sign_content]
  before_action :correct_user, only: [:destroy, :sign_content]

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
    if multi_factor_enabled
    else
      flash[:error] = "Activate multi factor authentication to sign messages!"
      redirect_to root_url
    end
  end

  # PATCH/PUT /messages/:id
  def update
    if message_params[:authenticated]
      pkey = OpenSSL::PKey::RSA.new(current_user.private_key)
      @message.sign_content(pkey)
      p @message.signature
      if @message.save
        flash[:info] = "Signature successfully created!"
      else
        flash[:error] = "Signature not created!"
      end
      redirect_to root_url
    else
      render 'edit'
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
    params.require(:message).permit(:content, :authenticated)
  end

  def correct_user
    @message = current_user.messages.find_by(id: params[:id])
    redirect_to root_url if @message.nil?
  end

  def multi_factor_enabled
    current_user.multi_factor_methods.any?
  end
end
