module LabelsHelper

  def label_tag(text)
    content_tag(:span, text, class: 'bg-success rounded py-1 px-2')
  end

end
