# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "creators/edit", type: :view do
  let(:creator) { Creator.new }

  before do
    assign(:creator, creator)
  end

  it 'renders the new creator form', :aggregate_failures do
    render
    expect(rendered).to have_field('creator_display_name',    name: 'creator[display_name]', text: '')
    expect(rendered).to have_field('creator_alternate_names', name: 'creator[alternate_names][]')
    expect(rendered).to have_field('creator_group',           name: 'creator[group]', text: 'unassigned')
    expect(rendered).to have_field('creator_repec',           name: 'creator[repec]', text: '')
    expect(rendered).to have_field('creator_viaf',            name: 'creator[viaf]', text: '')
    expect(rendered).to have_field('creator_active_creator',  name: 'creator[active_creator]', checked: true)

    expect(rendered).to have_selector("form[@action='#{creators_path}']")
  end

  it 'restricts groups to those provided by the Creator class' do
    render
    expect(rendered).to have_select('creator_group', options: ["unassigned", "staff", "consultant"])
  end

  context 'with validation errors' do
    let(:creator) { FactoryBot.build(:creator, id: 1, group: 'lawful-evil') }

    before do
      creator.validate
    end

    it 'displays a top-level error message' do
      render
      expect(rendered).to have_selector('.has-error', text: 'Please correct the 1 error below before saving.')
    end
  end
end
