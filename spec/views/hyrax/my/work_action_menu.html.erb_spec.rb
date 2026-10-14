# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/my/_work_action_menu', type: :view do
  before do
    allow(view).to receive(:can?).and_return(false)
    allow(view).to receive(:main_app).and_return(main_app)
    view.extend(Hyrax::TrophyHelper)
    allow(view).to receive(:display_trophy_link).and_return(nil)
  end

  context 'for permitted Export users' do
    # read_access_group_ssim: [] --> visibility: 'restricted'
    let(:document) { SolrDocument.new(id: 'abc123', read_access_group_ssim: []) }

    before do
      allow(view).to receive(:can?).with(:create, Export).and_return(true)
      render partial: 'hyrax/my/work_action_menu', locals: { document: document }
    end

    describe 'the express zip export form' do
      let(:zip_form) { Capybara.string(rendered).find('form#zip-export-abc123') }

      it 'displays the submit button' do
        expect(zip_form).to have_button(id: 'submit-zip-export-abc123')
      end

      it 'submits to the exports path' do
        expect(zip_form['action']).to eq main_app.exports_path
      end

      it 'includes the work id' do
        expect(zip_form).to have_selector("input[name='export[items][]'][value='abc123']", visible: :hidden)
      end

      it 'includes the work visibility' do
        expect(zip_form).to have_selector("input[name='export[visibility]'][value='restricted']", visible: :hidden)
      end

      it 'sets the export format to zip' do
        expect(zip_form).to have_selector("input[name='export[format]'][value='zip']", visible: :hidden)
      end
    end

    describe 'the express bag export form' do
      let(:bag_form) { Capybara.string(rendered).find('form#bag-export-def456') }
      # read_access_group_ssim: ['registered'] --> visibility: 'authenticated'
      let(:document) { SolrDocument.new(id: 'def456', read_access_group_ssim: ['registered']) }

      it 'displays the submit button' do
        expect(bag_form).to have_button(id: 'submit-bag-export-def456')
      end

      it 'submits to the exports path' do
        expect(bag_form['action']).to eq main_app.exports_path
      end

      it 'includes the work id' do
        expect(bag_form).to have_selector("input[name='export[items][]'][value='def456']", visible: :hidden)
      end

      it 'includes the work visibility' do
        expect(bag_form).to have_selector("input[name='export[visibility]'][value='authenticated']", visible: :hidden)
      end

      it 'sets the export format to bag' do
        expect(bag_form).to have_selector("input[name='export[format]'][value='bag']", visible: :hidden)
      end
    end
  end

  context 'for users without Export permissions' do
    let(:document) { SolrDocument.new(id: 'abc123') }

    before do
      allow(view).to receive(:can?).with(:create, Export).and_return(false)
      render partial: 'hyrax/my/work_action_menu', locals: { document: document }
    end

    it 'does not display express export options' do
      expect(rendered).not_to have_selector("form[action='#{main_app.exports_path}']")
    end
  end
end
