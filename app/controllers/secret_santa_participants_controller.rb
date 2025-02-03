# frozen_string_literal: false

class SecretSantaParticipantsController < ApplicationController
  load_and_authorize_resource :secret_santa, find_by: :slug
  # load_and_authorize_resource :secret_santa_participant, through: :secret_santa

  SECRET_SANTA_CLOSED = 'This Secret Santa has been completed and cannot be joined'.freeze

  def new
    @secret_santa = SecretSanta.find(params[:secret_santum_id])
    @secret_santa_participant = @secret_santa.secret_santa_participants.build
    unless current_user.guest?
      @secret_santa_participant.email = current_user.email
      @secret_santa_participant.first_name = current_user.first_name
      @secret_santa_participant.last_name = current_user.last_name
    end

    respond_to do |format|
      format.html do
        return redirect_to root_path, alert: SECRET_SANTA_CLOSED if @secret_santa.completed?
        render :new
      end
    end
  end

  def create
    @secret_santa = SecretSanta.find(params[:secret_santum_id])
    @secret_santa_participant = @secret_santa.secret_santa_participants.create(secret_santa_participant_params)

    respond_to do |format|
      format.html do
        if @secret_santa_participant.errors.any?
          render :new
        else
          flash[:success] = "You've successfully joined #{@secret_santa.name}"
          redirect_to secret_santum_path(@secret_santa), success: "You've successfully joined #{@secret_santa.name}"
        end
      end
    end
  end

  def resend_email
    @secret_santa = SecretSanta.find(params[:secret_santum_id])
    @secret_santa_participant = @secret_santa.secret_santa_participants.find(params[:secret_santa_participant_id])
    @secret_santa_participant_match = @secret_santa_participant.secret_santa_participant_match
    respond_to do |format|
      if SecretSantaService.new(@secret_santa).resend_email(match: @secret_santa_participant_match)
        flash[:success] = "Successfully resent email to #{@secret_santa_participant.name}"
      else
        flash[:error] = "Failed to resend email to #{@secret_santa_participant.name}. Please try again."
      end
      format.html { redirect_to match_secret_santum_path(@secret_santa) }
    end
  end

  private

  def secret_santa_participant_params
    params.require(:secret_santa_participant).permit(
      :id,
      :_destroy,
      user_attributes: %i[id first_name last_name email guest],
    )
  end
end
