# frozen_string_literal: false

class SecretSantaController < ApplicationController
  load_and_authorize_resource :secret_santa

  def index
    @my_secret_santas = SecretSanta.where(user: current_user) if current_user
    params[:active] ||= 'mine'
    if params[:search] && secret_santa_search_params[:email] && secret_santa_search_params[:name]
      @secret_santas = SecretSanta.by_email(secret_santa_search_params[:email])
                                  .by_name(secret_santa_search_params[:name])
    end
    respond_to do |format|
      format.html
    end
  end

  def create
    @secret_santa = SecretSanta.create(secret_santa_params)
    unlock_secret_santa(@secret_santa) unless current_user
    wizard(@secret_santa)

    respond_to do |format|
      format.html { render :new }
      format.js { render :new }
    end
  end

  def update
    @secret_santa = SecretSanta.find(params[:id])
    @secret_santa.update_attributes(secret_santa_params) if can_update?
    wizard(@secret_santa)

    respond_to do |format|
      if @step == 4
        format.html { redirect_to @secret_santa }
        format.js { redirect_to @secret_santa }
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  def new
    @secret_santa = SecretSanta.new
    wizard(@secret_santa)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @secret_santa = SecretSanta.find(params[:id])
    wizard(@secret_santa)

    respond_to do |format|
      format.html { render :new }
    end
  end

  def show
    @secret_santa = SecretSanta.find(params[:id])
    respond_to do |format|
      if can_access?(@secret_santa)
        format.html
        format.js { render js: "window.location = '#{secret_santum_path(@secret_santa)}'" }
      else
        format.html { redirect_to access_secret_santum_path(@secret_santa) }
        format.js { redirect_to access_secret_santum_path(@secret_santa) }
      end
    end
  end

  def match
    @secret_santa = SecretSanta.find(params[:id])
    @secret_santa.update_attributes(secret_santa_params) if can_update?
    @secret_santa.make_magic!
    respond_to do |format|
      format.html
    end
  end

  def unlock
    @secret_santa = SecretSanta.find(params[:id])
    unlock_secret_santa(@secret_santa) if @secret_santa.passphrase == params[:passphrase]

    respond_to do |format|
      if can_access?(@secret_santa)
        format.html { redirect_to @secret_santa }
      else
        flash.now[:error] = 'Incorrect passphrase.'
        format.html { render :access }
      end
    end
  end

  def access
    @secret_santa = SecretSanta.find(params[:id])
    respond_to do |format|
      if can_access?(@secret_santa)
        format.html { redirect_to secret_santum_path(@secret_santa) }
        format.js { render js: "window.location = '#{secret_santum_path(@secret_santa)}'" }
      else
        format.html
        format.js { render js: "window.location = '#{access_secret_santum_path(@secret_santa)}'" }
      end
    end
  end

  def clone
    og_secret_santa = SecretSanta.find(params[:id])
    secret_santa = og_secret_santa.clone

    respond_to do |format|
      if secret_santa
        flash[:success] = 'Secret Santa cloned successfully!'
        format.html { redirect_to edit_secret_santum_path(secret_santa) }
      else
        flash[:error] = 'Sorry! We failed to clone this Secret Santa.'
        format.html { redirect_to secret_santum_path(og_secret_santa) }
      end
    end
  end

  def destroy
    secret_santa = SecretSanta.find(params[:id])

    respond_to do |format|
      if secret_santa.complete?
        flash[:error] = 'Secret Santa could not be deleted since it has been completed.'
        format.html { redirect_to secret_santum_path(secret_santa) }
      else
        secret_santa.destroy
        flash[:success] = 'Secret Santa deleted successfully!'
        format.html { redirect_to secret_santa_path }
      end
    end
  end

  private

  def wizard(secret_santa)
    @step = wizard_step
    errors = secret_santa.errors.any?
    @step += 1 unless back? || errors.present?
    @step -= 1 if back?
    return if errors

    case @step
    when 1
      secret_santa.build_user(current_user.attributes) if current_user
      secret_santa.build_user(guest: Time.zone.now) unless secret_santa.user
    when 2
      secret_santa.secret_santa_participants.where(user_id: secret_santa.user_id).first_or_initialize
    when 3
      secret_santa.secret_santa_participants.each do |participant|
        participant.secret_santa_participant_exceptions.build
      end
    end
  end

  def wizard_step
    params[:step].try(:to_i) || 0
  end

  def back?
    @back ||= params[:commit] == 'Back'
  end

  def can_access?(secret_santa)
    return true if secret_santa.passphrase.blank?
    secret_santa.user == current_user || session.fetch(:secret_santa, []).include?(secret_santa.id)
  end

  def can_update?
    params[:secret_santa]
  end

  def unlock_secret_santa(secret_santa)
    session[:secret_santa] ||= []
    session[:secret_santa] << secret_santa.id
  end

  def secret_santa_params
    params.require(:secret_santa).permit(
      :name,
      :send_email,
      :email_subject,
      :email_content,
      :send_file,
      :filename,
      :file_content,
      :test_run,
      :passphrase,
      user_attributes: %i[id first_name last_name email guest],
      secret_santa_participants_attributes: [:id,
                                             :_destroy,
                                             user_attributes: %i[first_name last_name email guest],
                                             secret_santa_participant_exceptions_attributes: %i[id exception_id _destroy]]
    )
  end

  def secret_santa_search_params
    params.require(:search).permit(:name, :email)
  end
end
