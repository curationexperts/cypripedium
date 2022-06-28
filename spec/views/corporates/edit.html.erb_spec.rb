require 'rails_helper'

RSpec.describe "corporates/edit", type: :view do
  before do
    @corporate = assign(:corporate, Corporate.create!(
      corporate_name: "Test Corporate Name",
      corporate_state: "NY",
      corporate_city: "New York City"
    ))
  end

  it "renders the edit corporate form" do
    render

    assert_select "form[action=?][method=?]", corporate_path(@corporate), "post" do
      assert_select "input[name=?]", "corporate[corporate_name]"

      assert_select "select[name=?]", "corporate[corporate_state]"

      assert_select "input[name=?]", "corporate[corporate_city]"
    end
  end
end
