require 'rails_helper'

RSpec.describe "Products", type: :request do
	it "displays a product catalog" do
		get "/products"
		expect(response).to render_template(:index)
		expect(response).to have_http_status(:ok)
	end
end
