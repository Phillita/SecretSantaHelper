# frozen_string_literal: false

module SecretSantaHelper
  DEFAULT_WIZARD_VIEW_PATH = 'secret_santa/wizard/step_'.freeze
  MAX_WIZARD_STEP_NUMBER = 3
  WIZARD_ACTIVE_TAB_CLASS = 'active'.freeze

  def secret_santa_wizard_step(step)
    raise ArgumentError, 'Missing step' unless step
    "#{DEFAULT_WIZARD_VIEW_PATH}#{step}"
  end

  def exceptions_for_secret_santa_participant(participant_id, secret_santa)
    raise ArgumentError, 'Missing participant or secret santa.' unless participant_id && secret_santa
    SecretSantaParticipant.where(participantable: secret_santa).where.not(id: participant_id)
  end

  def max_secret_santa_step
    MAX_WIZARD_STEP_NUMBER
  end

  def active?(param, tab)
    param == tab ? 'active' : ''
  end

  # if nil id passed in, it will always return true
  # if an id is passed in, it will only return tru for the matching object id
  def autofocus_object?(id, current_form_object_id)
    id.nil? || current_form_object_id&.to_i == id&.to_i
  end
end
