require 'rails_helper'

RSpec.describe "corporates/index", type: :view do
  before(:each) do
    assign(:corporates, [
      Corporate.create!(
        corporate_name: "Corporate Name",
        corporate_state: "Corporate State",
        corporate_city: "Corporate City"
      ),
      Corporate.create!(
        corporate_name: "Corporate Name",
        corporate_state: "Corporate State",
        corporate_city: "Corporate City"
      )
    ])
  end

  it "renders a list of corporates" do
    render
    assert_select "tr>td", text: "Corporate Name".to_s, count: 2
    assert_select "tr>td", text: "Corporate State".to_s, count: 2
    assert_select "tr>td", text: "Corporate City".to_s, count: 2
  end
end
