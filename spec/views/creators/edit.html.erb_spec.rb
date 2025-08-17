# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "creators/edit", type: :view do
  let(:creator) { FactoryBot.build(:creator, id: 1) }

  before do
    allow(creator).to receive(:persisted?).and_return(true)
    assign(:creator, creator)
  end

  it 'renders the edit creator form', :aggregate_failures do
    render
    expect(rendered).to have_field('creator_display_name',    name: 'creator[display_name]')
    expect(rendered).to have_field('creator_alternate_names', name: 'creator[alternate_names][]')
    expect(rendered).to have_field('creator_group',           name: 'creator[group]')
    expect(rendered).to have_field('creator_repec',           name: 'creator[repec]')
    expect(rendered).to have_field('creator_viaf',            name: 'creator[viaf]')
    expect(rendered).to have_field('creator_active_creator',  name: 'creator[active_creator]')

    expect(rendered).to have_selector("form[@action='#{creator_path(creator)}']")
  end

  it 'restricts groups to those provided by the Creator class' do
    render
    expect(rendered).to have_select('creator_group', options: ["unassigned", "staff", "consultant"])
  end

  context 'with validation errors' do
    let(:creator) { FactoryBot.build(:creator, id: 1, display_name: '', group: 'lawful-evil') }

    before do
      creator.validate
    end

    it 'displays a top-level error message' do
      render
      expect(rendered).to have_selector('.has-error', text: 'Please correct the 2 errors below before saving.')
    end

    it 'tags invalid fields with error-classes', :aggregate_failures do
      render
      expect(rendered).to have_selector('.creator_display_name.has-error', text: "can't be blank")
      expect(rendered).to have_selector('.creator_group.has-error', text: 'is not included in the list')
    end
  end
end
