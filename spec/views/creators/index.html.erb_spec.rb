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
               group: 'staff',
               display_name: "Display Name",
               alternate_names: ["Alternate Names"],
               repec: "Repec",
               viaf: "Viaf"
             )
           ])
  end

  it 'renders a table of creators', :aggregate_failures do
    render
    expect(rendered).to have_selector('td.display_name', text: 'Display Name', count: 1)
    expect(rendered).to have_selector('td.group', text: 'staff', count: 1)
    expect(rendered).to have_selector('td.repec', text: 'psu51', count: 1)
    expect(rendered).to have_selector('td.active_creator', text: 'true', count: 2)
  end

  it 'provides an edit link for admins' do
    allow(controller.current_or_guest_user).to receive(:can?).with(:edit, Creator).and_return(true)
    render
    expect(rendered).to have_selector('td.edit', count: 2)
  end

  it 'suppresses the edit link for regular users' do
    allow(controller.current_or_guest_user).to receive(:can?).with(:edit, Creator).and_return(false)
    render
    expect(rendered).not_to have_selector('td.edit')
  end
end
