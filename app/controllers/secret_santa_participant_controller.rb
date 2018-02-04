# frozen_string_literal: false

class SecretSantaParticipantController < ApplicationController
  load_and_authorize_resource :secret_santa, find_by: :slug
  # load_and_authorize_resource :secret_santa_participant, through: :secret_santa

  def resend_email
    @secret_santa = SecretSanta.find(params[:secret_santum_id])
    @secret_santa_participant = @secret_santa.secret_santa_participants.find(params[:secret_santa_participant_id])
    @secret_santa_participant_match = @secret_santa_participant.secret_santa_participant_match
    respond_to do |format|
      if SecretSantaService.new(@secret_santa).resend_email(match: @secret_santa_participant_match)
        format.html { redirect_to match_secret_santum_path(@secret_santa), success: "Successfully resent email to #{@secret_santa_participant.name}" }
      else
        format.html { redirect_to match_secret_santum_path(@secret_santa), error: "Failed to resend email to #{@secret_santa_participant.name}. Please try again." }
      end
    end
  end
end
