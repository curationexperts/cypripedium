require 'rails_helper'

RSpec.describe "corporates/new", type: :view do
  before do
    assign(:corporate, Corporate.new(
      corporate_name: "MyString",
      corporate_state: "MyString",
      corporate_city: "MyString"
    ))
  end

  it "renders new corporate form" do
    render

    assert_select "form[action=?][method=?]", corporates_path, "post" do
      assert_select "input[name=?]", "corporate[corporate_name]"

      assert_select "select[name=?]", "corporate[corporate_state]"

      assert_select "input[name=?]", "corporate[corporate_city]"
    end
  end
end
