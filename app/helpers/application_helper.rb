module ApplicationHelper
  FLASH_CLASSES = {
    success: 'alert-success',
    error: 'alert-danger',
    alert: 'alert-warning',
    notice: 'alert-info'
  }

  def page_title(text = nil)
    content_for :title do
      "SecretSantaApp#{': ' + text if text}"
    end
  end

  def flash_class(flash_type)
    FLASH_CLASSES.fetch(flash_type.to_sym, flash_type.to_s)
  end
  alias_method :notification_class, :flash_class
end
