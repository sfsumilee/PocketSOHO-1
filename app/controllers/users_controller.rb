class UsersController < ApplicationController
  before_filter :set_user

  def new
    @new_customer = @user.businesses.first.customers.new
  end

  def create
    @new_customer = @user.businesses.first.customers.create(params[:customer])
    redirect_to root_path
  end

  def edit
    if params[:id].to_i != @user.id && @user.type == "Customer"
      redirect_to root_path
      flash[:error] = 'You cannot access this page.'
    end

  end

  def show
    @profile_user = User.find(params[:id])
    if @user.type == "BusinessOwner" && @profile_user.type == "Customer"
      @conversation = Conversation.where( "business_owner_id = ? AND customer_id = ?", @user.id, @profile_user.id ).first
    else
      @conversation = Conversation.where( "business_owner_id = ? AND customer_id = ?", @profile_user.id, @user.id ).first
    end
  end

  def update
    user_params = params[@user.class.name.underscore.downcase.to_sym]
    user_params.permit!
    @user.update( user_params )
    if @user.type == "Customer"
      biz_id = params["business_id"].split(' ').last.to_i
      if biz_id != 0
        @user.update(business_id: biz_id)
      end
    end
    @user.save
    if @user.business_id == nil
      redirect_to new_business_path
    else
      redirect_to user_path(@user)
    end
  end

  def destroy

  end

  def settings
    @businesses = Business.where("business_owner_id = ?", @user.id )
  end

  # def change_password
  #   @user = current_user
  # end

  # def update_password
  #   @user = current_user
  #   redirect_to root_path
  # end

   def update_password
    @user = User.find(current_user.id)
    if @user.type == "BusinessOwner"
      user_params = params["business_owner"]
    else
      user_params = params["customer"]
    end
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end

  private

  # def user_params
  #   params.require(:user).permit(:first_name, :last_name, :city, :state, :email, :image_url, :phone, :password, :password_confirmation, :current_password)
  # end
end
