# frozen_string_literal: false

module ApplicationHelper
  FLASH_CLASSES = {
    success: 'alert-success',
    error: 'alert-danger',
    alert: 'alert-warning',
    notice: 'alert-info'
  }

  def page_title(text = nil)
    content_for :title do
      "AppHelper#{': ' + text if text}"
    end
  end

  def flash_class(flash_type)
    FLASH_CLASSES.fetch(flash_type.to_sym, flash_type.to_s)
  end
  alias_method :notification_class, :flash_class

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_class
    devise_mapping.to
  end
end
