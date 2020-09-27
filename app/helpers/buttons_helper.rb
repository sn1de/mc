module ButtonsHelper

  def button_link_to(text, url, hook: nil, data: {}, method: nil)
    options = {
      class: 'btn btn-md btn-primary btn-block rounded-0 text-uppercase py-2 px-3 text-white',
      data: data.merge(hook: hook),
      method: method
    }
    link_to(text, url, options)
  end

  def button_primary_tag(text)
    options = {
      class: 'btn btn-md btn-primary rounded-0 text-uppercase py-2 px-3 text-white',
    }
    button_tag(text, options)
  end
end
