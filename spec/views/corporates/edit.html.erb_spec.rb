require 'rails_helper'

RSpec.describe "corporates/edit", type: :view do
  before(:each) do
    @corporate = assign(:corporate, Corporate.create!(
      corporate_name: "MyString",
      corporate_state: "MyString",
      corporate_city: "MyString"
    ))
  end

  it "renders the edit corporate form" do
    render

    assert_select "form[action=?][method=?]", corporate_path(@corporate), "post" do

      assert_select "input[name=?]", "corporate[corporate_name]"

      assert_select "input[name=?]", "corporate[corporate_state]"

      assert_select "input[name=?]", "corporate[corporate_city]"
    end
  end
end
