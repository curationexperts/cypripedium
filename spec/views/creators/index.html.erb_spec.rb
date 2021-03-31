# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "creators/index", type: :view do
  before do
    assign(:creators, [
             Creator.create!(
               display_name: "Surname, G. N. (Given Names), 1927-",
               alternate_names: ["Alternate Name", "Yet Another Name"],
               repec: "psu51",
               viaf: "78689889"
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
    assert_select "tr>td", text: "Display Name".to_s, count: 1
    assert_select "tr>td", text: "Alternate Names".to_s, count: 1
    assert_select "tr>td", text: "Repec".to_s, count: 1
    assert_select "tr>td", text: "Viaf".to_s, count: 1
    assert_select "tr>td", text: "Surname, G. N. (Given Names), 1927-".to_s, count: 1
    assert_select "tr>td", text: ["Alternate Name", "Yet Another Name"].to_s, count: 1
  end
end
