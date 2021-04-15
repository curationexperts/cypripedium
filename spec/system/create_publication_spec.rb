# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Publication`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Create a Publication', type: :system, js: true do
  context 'a logged in admin user' do
    let(:user) { FactoryBot.create(:admin) }
    before do
      login_as user
      AdminSet.find_or_create_default_admin_set_id
    end

    context "with a creator from a controlled vocabulary" do
      before do
        creator_array = [
          { "id": "http://id.loc.gov/authorities/names/no2003126550", "label": "Cagetti, Marco" },
          { "id": "https://ideas.repec.org/f/pca1299.html", "label": "Cai, Zhifeng" },
          { "id": "https://ideas.repec.org/e/pca150.html", "label": "Calsamiglia, Caterina" },
          { "id": "https://ideas.repec.org/f/pca694.html", "label": "Calvo, Guillermo A." },
          { "id": "https://ideas.repec.org/f/pca371.html", "label": "Camargo, Braz" },
          { "id": "https://ideas.repec.org/e/pca89.html", "label": "Campbell, Jeffrey R." },
          { "id": "https://ideas.repec.org/e/pca50.html", "label": "Canova, Fabio" },
          { "id": "https://ideas.repec.org/e/pca77.html", "label": "Caplin, Andrew" },
          { "id": "https://ideas.repec.org/f/pca1029.html", "label": "Carapella, Francesca" },
          { "id": "https://ideas.repec.org/e/pca42.html", "label": "Carlstrom, Charles T., 1960-" },
          { "id": "https://ideas.repec.org/f/pca205.html", "label": "Caselli, Francesco, 1966-" },
          { "id": "https://ideas.repec.org/e/pca73.html", "label": "Caucutt, Elizabeth M. (Elizabeth Miriam)" },
          { "id": "https://ideas.repec.org/f/pca963.html", "label": "Cavalcanti, Ricardo de Oliveira" }
        ]
        creator_array.each do |creator|
          Creator.create!(
            display_name: creator[:label]
          )
        end
      end
      scenario 'fill in and submit the title and creator' do
        visit '/concern/publications/new'
        fill_in 'Title', with: 'My Title'
        fill_in('Creator', with: 'Cag')
        expect(page).to have_content('Cagetti, Marco')
        expect(page).not_to have_content('Cai, Zhifeng')
        # Select the first item in the autocomplete list
        find('.ui-menu-item-wrapper').click
        creator_identifier = Creator.find_by(display_name: "Cagetti, Marco").id
        fill_in('Creator identifier', with: creator_identifier)
        click_link 'Files'

        execute_script("$('.fileinput-button input:first').css({'opacity':'1', 'display':'block', 'position':'relative'})")
        attach_file('files[]', File.absolute_path(file_fixture('pdf-sample.pdf')))
        sleep(1)
        find('#agreement').click
        find('#with_files_submit').click
        sleep(5)
        expect(page).to have_selector 'h1', text: 'My Title'
        expect(page).to have_content('Cagetti, Marco')
        pub = Publication.first
        expect(pub.creator).to eq ['Cagetti, Marco']
        expect(pub.creator_id).to eq [creator_identifier.to_s]
        # expect(pub.creator).to be_an_instance_of ActiveTriples::Relation
      end
    end

    scenario 'fill in and submit the form' do
      visit '/concern/publications/new'
      expect(page).to have_content "Add New Publication"

      # Only the 'title' field should be required
      expect(page).to have_css('li#required-metadata.incomplete')
      fill_in 'Title', with: 'Title'
      click_on 'Title'
      expect(page).to have_css('li#required-metadata.complete')

      find('#publication_series').click
      fill_in 'Series', with: 'Staff Reports (Federal Reserve Bank of Minneapolis. Research Division.)'
      fill_in 'Issue number', with: '111'
      fill_in 'Date Created', with: '2019-05-01'
      fill_in 'Keyword', with: 'Keyword'
      fill_in 'Subject (JEL)', with: 'A10 - General Economics: General'
      fill_in 'Abstract', with: 'Abstract'
      fill_in 'Description', with: 'Description'
      fill_in 'DOI', with: 'DOI'
      fill_in 'Related URL', with: '<http://curationexperts.com>'
      fill_in 'Corporate Author', with: 'Federal Reserve Bank of Minneapolis. Research Division.'
      fill_in 'Publisher', with: 'Federal Reserve Bank of Minneapolis. Research Division.'
      select 'Article', from: 'Resource type'

      click_on 'Additional fields'

      fill_in 'Contributor', with: 'Contributor'
      select 'In Copyright', from: 'Rights statement'
      fill_in 'Language', with: 'Language'
      fill_in 'Source', with: 'Source'
      fill_in 'Alternative Title', with: 'Alternative Title'
      fill_in 'Bibliographic Citation', with: 'Bibliographic Citation'
      fill_in 'Date Available', with: 'Date Available'
      fill_in 'Extent', with: 'Extent'
      fill_in 'Relation: Has Part', with: 'Relation: Has Part'
      fill_in 'Relation: Is Version Of', with: 'Relation: Is Version Of'
      fill_in 'Relation: Has Version', with: 'Relation: Has Version'
      fill_in 'Relation: Is Replaced By', with: 'Relation: Is Replaced By'
      fill_in 'Relation: Requires', with: 'Relation: Requires'
      fill_in 'Spatial', with: 'Spatial'
      fill_in 'Temporal', with: 'Temporal'
      fill_in 'Table of Contents', with: 'Table of Contents'

      click_link 'Files'

      execute_script("$('.fileinput-button input:first').css({'opacity':'1', 'display':'block', 'position':'relative'})")
      attach_file('files[]', File.absolute_path(file_fixture('pdf-sample.pdf')))
      sleep(1)

      choose('publication_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      # These lines are for debugging, should this test fail
      # puts "Required metadata: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').requiredFields.areComplete})}"
      # puts "Required files: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').uploads.hasFiles})}"
      # puts "Agreement : #{page.evaluate_script(%{$('#form-progress').data('save_work_control').depositAgreement.isAccepted})}"

      # TODO: Capybara / Selenium not re-enabling submit button when agreement initializer set to false
      # so no work show page appears. Save the form
      find('#agreement').click
      find('#with_files_submit').click
      sleep(5)

      # Now we are on the show page for the new record
      expect(page).to have_selector 'h1', text: 'Title'
      expect(page).to have_content('Staff Reports (Federal Reserve Bank of Minneapolis. Research Division.)')
      expect(page).to have_content('111')
      expect(page).to have_content('2019-05-01')
      expect(page).to have_content('Description')
      expect(page).to have_content('Abstract')
      expect(page).to have_content('A10 - General Economics: General')
      expect(page).to have_content('Keyword')
      expect(page).to have_content('Table of Contents')
      expect(page).to have_link('http://curationexperts.com')
      expect(page).to have_content('Alternative Title')
      expect(page).to have_content('Date Available')
      expect(page).to have_content('Contributor')
      expect(page).to have_content('Language')
      expect(page).to have_content('Federal Reserve Bank of Minneapolis. Research Division.')
      expect(page).to have_content('Federal Reserve Bank of Minneapolis. Research Division.')
      expect(page).to have_content('Article')
      expect(page).to have_content('Source')
      expect(page).to have_content('Temporal')
      expect(page).to have_content('Extent')
      expect(page).to have_content('Bibliographic Citation')
      expect(page).to have_content('DOI')
      expect(page).not_to have_content('Relation: Has Part')
      expect(page).not_to have_content('Relation: Is Version Of')
      expect(page).not_to have_content('Relation: Has Version')
      expect(page).not_to have_content('Relation: Is Replaced By')
      expect(page).not_to have_content('Relation: Requires')
      expect(page).to have_content('Spatial')
      expect(page).to have_content('Title')
    end
  end
end
