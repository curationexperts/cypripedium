# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "creators/edit", type: :view do
  before do
    @creator = assign(:creator, Creator.create!(
      display_name: "MyString",
      alternate_names: "MyString",
      repec: "MyString",
      viaf: "MyString"
    ))
  end

  skip "renders the edit creator form" do
    render

    assert_select "form[action=?][method=?]", creator_path(@creator), "post" do
      assert_select "input[name=?]", "creator[display_name]"

      assert_select "input[name=?]", "creator[alternate_names]"

      assert_select "input[name=?]", "creator[repec]"

      assert_select "input[name=?]", "creator[viaf]"
    end
  end
end
