class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.friendly.find(params[:id])
    authorize @user
  end

  def edit
    @user = User.friendly.find(params[:id])
    authorize @user
  end

  def update
    @user = User.friendly.find(params[:id])
    authorize @user

    binding.pry

    if @user.update(user_params)
      flash[:notice] = 'Profile Updated!'
      redirect_to @user
    else
      render :edit
    end
  end

  def invite
    @user = User.friendly.find(params[:id])
    authorize @user

    @team = current_user.current_team
    @team.team_requests << TeamRequest.new(
      user: @user,
      team: @team,
      approved: false,
      user_request: false
    )
    if @team.save
      flash[:notice] = 'Team Request Sent'  
    else
      flash[:alert] = 'An error occured during invite'
    end
    redirect_to @user
  end

  def bg_check
  end


  private
  def user_params
    params.require(:user).permit(
      :about,
      :avatar,
      :school,
      :grade,

      :home_city,
      :home_state,
      :home_country,
      :postal_code,

      :salutation,
      :science,
      :engineering,
      :project_management,
      :finance,
      :marketing,
      :design,
      :connect_with_other,

      :event_id,
    )
  end

end
