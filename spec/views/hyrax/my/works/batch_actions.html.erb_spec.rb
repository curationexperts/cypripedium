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

    it 'displays the Create Export Package button' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_button(id: 'create-export-package')
    end

    it 'includes a form targeting the exports path' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_selector("form#export-form[action='#{main_app.confirm_exports_path}'][method='post']")
    end

    it 'includes a hidden items field' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_selector("input[name='export[items][]'][value='']", visible: :hidden)
    end

    it 'includes an authenticity token' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).to have_selector("input[name='authenticity_token']", visible: :hidden)
    end
  end

  context 'for users without Export permissions' do
    it 'does not display the Create button' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).not_to have_button(id: 'create-export-package')
    end

    it 'does not include the export form' do
      render partial: 'hyrax/my/works/batch_actions'
      expect(rendered).not_to have_selector('form#export-form')
    end
  end
end
