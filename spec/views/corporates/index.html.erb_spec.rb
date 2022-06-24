require 'rails_helper'

RSpec.describe "corporates/index", type: :view do
  before do
    assign(
      :corporates,
      [
        Corporate.create!(
          corporate_name: "Corporate Name1",
          corporate_state: "Corporate State1",
          corporate_city: "Corporate City1"
        ),
        Corporate.create!(
          corporate_name: "Corporate Name2",
          corporate_state: "Corporate State2",
          corporate_city: "Corporate City2"
        )
      ]
    )
  end

  it "renders a list of corporates" do
    render
    assert_select "tr>td", text: "Corporate Name1".to_s, count: 1
    assert_select "tr>td", text: "Corporate State1".to_s, count: 1
    assert_select "tr>td", text: "Corporate City1".to_s, count: 1
  end
end
