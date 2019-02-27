class StaticPagesController < ApplicationController
  def home
    @message = current_user.messages.build if logged_in?
  end

  def contact
  end

  def about
  end
end
