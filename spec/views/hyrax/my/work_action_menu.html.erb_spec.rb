# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/my/_work_action_menu', type: :view do
  let(:document) { SolrDocument.new(id: 'abc123') }

  before do
    allow(view).to receive(:can?).and_return(false)
    allow(view).to receive(:main_app).and_return(main_app)
    view.extend(Hyrax::TrophyHelper)
    allow(view).to receive(:display_trophy_link).and_return(nil)
  end

  context 'for users with Export permissions' do
    before do
      allow(view).to receive(:can?).with(:create, Export).and_return(true)
    end

    it 'displays the Create BagIt Export button' do
      render partial: 'hyrax/my/work_action_menu', locals: { document: document }
      expect(rendered).to have_button('Create BagIt Export')
    end

    it 'submits to the exports path' do
      render partial: 'hyrax/my/work_action_menu', locals: { document: document }
      expect(rendered).to have_selector("form[action='#{main_app.exports_path}']")
    end

    it 'includes the work id as an item' do
      render partial: 'hyrax/my/work_action_menu', locals: { document: document }
      expect(rendered).to have_selector("input[name='export[items][]'][value='abc123']", visible: :hidden)
    end
  end

  context 'for users without Export permissions' do
    it 'does not display the Create BagIt Export button' do
      render partial: 'hyrax/my/work_action_menu', locals: { document: document }
      expect(rendered).not_to have_button('Create BagIt Export')
    end
  end
end
