class SecretSantaController < ApplicationController
  load_and_authorize_resource :secret_santa

  def create
    @secret_santa = SecretSanta.create(secret_santa_params)
    wizard(@secret_santa)

    respond_to do |format|
      format.html { render :new }
    end
  end

  def update
    @secret_santa = SecretSanta.find(params[:id])
    @secret_santa.update_attributes(secret_santa_params) if can_update?
    wizard(@secret_santa)

    respond_to do |format|
      if current_user && @step == 6
        format.html { redirect_to @secret_santa }
      elsif @step == 7
        format.html { redirect_to @secret_santa }
      else
        format.html { render :new }
      end
    end
  end

  def new
    @secret_santa = SecretSanta.new
    wizard(@secret_santa)

    respond_to do |format|
      format.html
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
      else
        format.html { redirect_to access_secret_santum_path(@secret_santa) }
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

    if @secret_santa.passphrase == params[:passphrase]
      session[:secret_santa] ||= []
      session[:secret_santa] << params[:id]
    end

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
      format.html
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
    when 2
      secret_santa.build_user(guest: Time.zone.now) unless secret_santa.user
    when 3
      secret_santa.secret_santa_participants.where(user_id: secret_santa.user_id).first_or_initialize
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
    secret_santa.user == current_user || session.fetch(:secret_santa, []).include?(params[:id])
  end

  def can_update?
    params[:secret_santa]
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
      user_attributes: [:first_name, :last_name, :email, :guest],
      secret_santa_participants_attributes: [:id,
                                             :_destroy,
                                             user_attributes: [:first_name, :last_name, :email, :guest],
                                             secret_santa_participant_exceptions_attributes: [:id, :exception_id, :_destroy]]
    )
  end
end
