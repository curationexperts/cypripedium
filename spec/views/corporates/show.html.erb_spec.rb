require 'rails_helper'

RSpec.describe "corporates/show", type: :view do
  before(:each) do
    @corporate = assign(:corporate, Corporate.create!(
      corporate_name: "Corporate Name",
      corporate_state: "Corporate State",
      corporate_city: "Corporate City"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Corporate Name/)
    expect(rendered).to match(/Corporate State/)
    expect(rendered).to match(/Corporate City/)
  end
end
