# frozen_string_literal: true

class DateTimePickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    template.content_tag(:div, class: 'input-group date form_datetime') do
      template.concat @builder.text_field(attribute_name, merge_wrapper_options(input_html_options, wrapper_options))
      template.concat span_table
    end
  end

  def input_html_options
    super.merge(class: 'form-control', readonly: true)
  end

  def span_table
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_table
    end
  end

  def icon_table
    "<span class='glyphicon glyphicon-th'></span>".html_safe
  end
end
