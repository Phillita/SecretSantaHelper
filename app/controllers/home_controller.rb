class HomeController < ApplicationController
  def index
    @secret_santa = SecretSanta.new
    @secret_santa.build_user(guest: Time.zone.now)
    @secret_santa.secret_santa_participants.build
    @secret_santa.secret_santa_participants.first.build_user

    respond_to do |format|
      format.html { render layout: 'home' }
    end
  end
end
