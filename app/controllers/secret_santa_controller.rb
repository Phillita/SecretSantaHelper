class SecretSantaController < ApplicationController
  load_and_authorize_resource :secret_santa

  def create
    @secret_santa = SecretSanta.create(secret_santa_params)
    wizard(@secret_santa)

    respond_to do |format|
      format.html { render :new }
      format.json { render json: @resource }
    end
  end

  def update
    @secret_santa = SecretSanta.find(params[:id])
    @secret_santa.update_attributes(secret_santa_params)
    wizard(@secret_santa)

    respond_to do |format|
      if @step == 6
        format.html { redirect_to @secret_santa }
      else
        format.html { render :new }
      end
      format.json { render json: @resource }
    end
  end

  def new
    @secret_santa = SecretSanta.new
    wizard(@secret_santa)

    respond_to do |format|
      format.html
      format.json { render json: @resource }
    end
  end

  def edit
    @secret_santa = SecretSanta.find(params[:id])
    wizard(@secret_santa)

    respond_to do |format|
      format.html { render :new }
      format.json { render json: @resource }
    end
  end

  def show
    @secret_santa = SecretSanta.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @resource }
    end
  end

  def match
    @secret_santa = SecretSanta.find(params[:id])
    @secret_santa.update_attributes(secret_santa_params)
    @santa_service = SecretSantaService.new(@secret_santa)
    @santa_service.make_magic!
    respond_to do |format|
      format.html
      format.json { render json: @resource }
    end
  end

  private

  def wizard(secret_santa)
    @step = wizard_step
    errors = secret_santa.errors.any?
    @step += 1 unless back? || errors.present?
    @step -= 1 if back?
    case @step
    when 2
      secret_santa.build_user(guest: Time.zone.now) unless secret_santa.user
    when 3
      secret_santa.secret_santa_participants.where(user_id: secret_santa.user_id).first_or_initialize
    end unless errors
  end

  def wizard_step
    params[:step].try(:to_i) || 0
  end

  def back?
    params[:commit] == 'Back'
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
      user_attributes: [:first_name, :last_name, :email, :guest],
      secret_santa_participants_attributes: [:id,
                                             :_destroy,
                                             user_attributes: [:first_name, :last_name, :email, :guest],
                                             secret_santa_participant_exceptions_attributes: [:id, :exception_id, :_destroy]]
    )
  end
end
