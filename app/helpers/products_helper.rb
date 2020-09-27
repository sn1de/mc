module ProductsHelper
  def product_photo_tag(product)
    image_tag(product.photo, class: 'd-block w-100')
  end

  def product_name_tag(product)
    content_tag(:h4, product.name, class: 'text-white m-0 p-3 position-relative z-index-1')
  end

  def product_name_mask_tag(product)
    content_tag(:div, nil, class: 'bg-black opacity-3 position-absolute top-0 left-0 right-0 bottom-0')
  end

  def product_quantity_tag(product)
    content_tag(:div, label_tag("#{product.quantity} in stock"), class: 'text-bold text-right text-white')
  end

  def product_price_tag(product)
    content_tag(:h5, number_to_currency(product.price), class: 'text-bold flex-grow-1 m-0')
  end

  def product_description_tag(product)
    content_tag(:div, product.description, class: 'p-3 bg-light text-muted m-0 h-sm-200-px')
  end

  def product_buy_button(product)
    content_tag(:div, class: 'p-3 p-sm-0 bg-light') do
      button_link_to('Buy this Product', new_order_path(order: { product_id: product.id }))
    end
  end
end
