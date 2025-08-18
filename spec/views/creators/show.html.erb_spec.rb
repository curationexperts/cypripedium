# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "creators/show", type: :view do
  let(:creator) { FactoryBot.build(:creator, id: 1) }

  before do
    allow(creator).to receive(:persisted?).and_return(true)
    assign(:creator, creator)
  end

  it 'renders attributes', :aggregate_failures do
    render
    expect(rendered).to have_selector('.display_name .attribute_value', text: creator.display_name)
    expect(rendered).to have_selector('.active_creator .attribute_value', text: creator.active_creator)
    expect(rendered).to have_selector('.group .attribute_value', text: creator.group)
    expect(rendered).to have_selector('.repec .attribute_value', text: creator.repec)
    expect(rendered).to have_selector('.viaf .attribute_value', text: creator.viaf)
    expect(rendered).to have_selector('.alternate_names .attribute_value', text: creator.alternate_names.last)
  end

  it 'provides an edit link for admins' do
    allow(controller.current_or_guest_user).to receive(:can?).with(:edit, Creator).and_return(true)
    render
    expect(rendered).to have_link('Edit', href: edit_creator_path(creator))
  end

  it 'suppresses the edit link for regular users' do
    allow(controller.current_or_guest_user).to receive(:can?).with(:edit, Creator).and_return(false)
    render
    expect(rendered).not_to have_link('Edit')
  end
end
