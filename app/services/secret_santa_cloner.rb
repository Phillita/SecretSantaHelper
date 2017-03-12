class SecretSantaCloner
  attr_reader :cloned_secret_santa

  def initialize(secret_santa)
    @secret_santa = secret_santa
    @cloned_secret_santa = secret_santa.dup
  end

  def clone
    ActiveRecord::Base.transaction do
      clone_details
      clone_participants
      clone_participant_exceptions
      @cloned_secret_santa.save!
    end
  end

  private

  def clone_details
    @cloned_secret_santa.name = "Cloned: #{@secret_santa.name}"
    @cloned_secret_santa.last_run_on = nil
    @cloned_secret_santa.save!
  rescue => e
    raise SantaExceptions::CloneError, "CloneDetails: #{e.message}"
  end

  def clone_participants
    @secret_santa.secret_santa_participants.each do |participant|
      @cloned_secret_santa.secret_santa_participants.build(user_id: participant.user_id)
    end
  rescue => e
    raise SantaExceptions::CloneError, "CloneParticipants: #{e.message}"
  end

  def clone_participant_exceptions
    @secret_santa.secret_santa_participants.each do |participant|
      participant.secret_santa_participant_exceptions.includes(:exception).each do |participant_exception|
        cloned_participant = @cloned_secret_santa.secret_santa_participants
                                                 .select { |p| p.user_id == participant.user_id }
                                                 .first
        cloned_participant_exception = @cloned_secret_santa.secret_santa_participants
                                                           .select { |p| p.user_id == participant_exception.exception.user_id }
                                                           .first
        cloned_participant.secret_santa_participant_exceptions.build(exception: cloned_participant_exception)
      end
    end
  rescue => e
    raise SantaExceptions::CloneError, "CloneParticipantExceptions: #{e.message}"
  end
end
