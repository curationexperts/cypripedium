# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "creators/new", type: :view do
  before do
    assign(:creator, Creator.new(
      display_name: "MyString",
      alternate_names: "MyString",
      repec: "MyString",
      viaf: "MyString"
    ))
  end

  it "renders new creator form" do
    render

    assert_select "form[action=?][method=?]", creators_path, "post" do
      assert_select "input[name=?]", "creator[display_name]"

      assert_select "input[name=?]", "creator[alternate_names]"

      assert_select "input[name=?]", "creator[repec]"

      assert_select "input[name=?]", "creator[viaf]"
    end
  end
end
