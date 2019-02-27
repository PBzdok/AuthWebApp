class MessagesController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      flash[:success] = "Message created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def destroy
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
