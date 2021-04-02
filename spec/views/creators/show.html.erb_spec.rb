# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "creators/show", type: :view do
  before do
    @creator = assign(:creator, Creator.create!(
      display_name: "Display Name",
      alternate_names: "Alternate Names",
      repec: "Repec",
      viaf: "Viaf"
    ))
  end

  skip "renders attributes in <p>" do
    render
    expect(rendered).to match(/Display Name/)
    expect(rendered).to match(/Alternate Names/)
    expect(rendered).to match(/Repec/)
    expect(rendered).to match(/Viaf/)
  end
end
