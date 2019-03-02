class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @message = current_user.messages.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end

  end

  def contact
  end

  def about
  end
end
