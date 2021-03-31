require 'rails_helper'

RSpec.describe "creators/index", type: :view do
  before(:each) do
    assign(:creators, [
      Creator.create!(
        display_name: "Display Name",
        alternate_names: "Alternate Names",
        repec: "Repec",
        viaf: "Viaf"
      ),
      Creator.create!(
        display_name: "Display Name",
        alternate_names: "Alternate Names",
        repec: "Repec",
        viaf: "Viaf"
      )
    ])
  end

  it "renders a list of creators" do
    render
    assert_select "tr>td", text: "Display Name".to_s, count: 2
    assert_select "tr>td", text: "Alternate Names".to_s, count: 2
    assert_select "tr>td", text: "Repec".to_s, count: 2
    assert_select "tr>td", text: "Viaf".to_s, count: 2
  end
end
