# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/my/works/_batch_actions', type: :view do
  before do
    allow(view).to receive(:can?).and_return(false)
    allow(view).to receive(:main_app).and_return(main_app)
    view.extend(Hyrax::BatchEditsHelper)
    allow(view).to receive(:batch_delete).and_return('')
    assign(:user_collections, [])
  end

  context 'for users with Export permissions' do
    before do
      allow(view).to receive(:can?).with(:create, Export).and_return(true)
    end

    it 'displays the Create BagIt Export button' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_button('Create BagIt Export')
    end

    it 'includes a form targeting the exports path' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_selector("form#export-form[action='#{main_app.exports_path}'][method='post']")
    end

    it 'includes the bag format as a hidden field' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_selector("input[name='export[format]'][value='bag']", visible: :hidden)
    end

    it 'includes an authenticity token' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_selector("input[name='authenticity_token']", visible: :hidden)
    end
  end

  context 'for users without Export permissions' do
    it 'does not display the Create BagIt Export button' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).not_to have_button('Create BagIt Export')
    end

    it 'does not include the export form' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).not_to have_selector('form#export-form')
    end
  end
end
