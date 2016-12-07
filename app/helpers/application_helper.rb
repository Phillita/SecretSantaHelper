module ApplicationHelper
  def page_title(text = nil)
    content_for :title do
      "SecretSantaApp#{': ' + text if text}"
    end
  end
end
