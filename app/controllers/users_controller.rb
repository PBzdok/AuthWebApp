class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :verify_otp]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :verify_otp]
  before_action :correct_user, only: [:edit, :update, :destroy, :verify_otp]

  # GET /users
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    @messages = @user.messages.paginate(page: params[:page])
    @auth_methods = @user.multi_factor_methods
    redirect_to(root_url) && return unless @user.activated?
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    initialize_u2f
    @user = User.find(params[:id])
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      flash[:info] = "User successfully updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    flash[:info] = "User was successfully destroyed."
    redirect_to users_url
  end

  # GET /users/:id/verify_otp
  def verify_otp
    respond_to do |format|
      format.html { redirect_to @user }
      format.json do
        if @user.verify_totp(user_params[:totp])
          session[:authentication_token] = @user.authentication_token
          render json: { totp_valid: true,
                         authentication_token: @user.authentication_token }
        else
          render json: { totp_valid: false }
        end
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :totp_activated, :totp, :u2f_activated)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Confirms a correct logged-in user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def initialize_u2f
    # Generate one for each version of U2F, currently only `U2F_V2`
    @registration_requests = u2f.registration_requests

    # Store challenges. We need them for the verification step
    session[:challenges] = @registration_requests.map(&:challenge)

    # Fetch existing Registrations from your db and generate SignRequests
    key_handles = U2fRegistration.all.map(&:key_handle)
    @sign_requests = u2f.authentication_requests(key_handles)

    @app_id = u2f.app_id
  end
end
