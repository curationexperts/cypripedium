# frozen_string_literal: true
RSpec.shared_examples 'standard work requests for' do |work_class|
  before(:context) do
    DatabaseCleaner.clean_with(:truncation)
    ActiveFedora::Cleaner.clean!
    Hyrax::AdminSetCreateService.find_or_create_default_admin_set
  end

  describe 'request to' do
    let(:work_type) { work_class.model_name.param_key }
    let(:work) { FactoryBot.create(work_type, **valid_attributes) }
    let(:admin) { FactoryBot.create(:admin) }
    let(:valid_attributes) { { title: ['A test title'], series: ['Staff report'] } }
    let(:invalid_attributes) { { title: [''] } } # Title can't be blank
    let(:page) { Capybara.string(response.body) }

    before do
      sign_in admin
    end

    describe 'GET /index', :aggregate_failures do
      it 'renders the work' do
        work # ensure the work exists before visiting /catalog
        # There is no index just for works, the catalog is basically
        # the index for the application
        get '/catalog'
        expect(response).to have_http_status(:ok)
        item = page.find("li#document_#{work.id}")
        expect(item).to have_link('A test title', href: polymorphic_path(work))
      end
    end

    describe 'GET /show', :aggregate_failures do
      it 'renders a successful response' do
        get polymorphic_path(work)
        expect(response).to have_http_status(:ok)
        expect(page).to have_css('.work-title-wrapper h1', text: 'A test title')
        expect(page).to have_css('.attribute-series', text: 'Staff report')
      end
    end

    describe 'GET /new' do
      it 'renders a successful response' do
        get polymorphic_path(work_class, action: :new)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /edit' do
      it 'renders a successful response' do
        get polymorphic_path(work, action: :edit)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST /create' do
      let(:work_path_pattern) { %r{#{polymorphic_path(work_class, locale: nil)}/[^/?]+} }

      context 'with valid parameters' do
        it 'creates a new work and redirects to it', :aggregate_failures do
          expect {
            post polymorphic_path(work_class), params: { work_type => valid_attributes }
          }.to change(work_class, :count).by(1)
          expect(response).to redirect_to(work_path_pattern)
          follow_redirect!
          expect(page).to have_css('.work-title-wrapper h1', text: 'A test title')
          expect(page).to have_css('.attribute-series', text: 'Staff report')
        end
      end

      context 'with invalid parameters' do
        it 're-renders the new work form with an error', :aggregate_failures do
          expect {
            post polymorphic_path(work_class), params: { work_type => invalid_attributes }
          }.to change(work_class, :count).by(0)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_css('div.alert-danger[role="alert"]', text: 'Title your work must have a title.')

          form = page.find('form')
          expect(form['id']).to eq("new_#{work_type}")
        end
      end

      context 'with an unauthenticated user' do
        before do
          sign_out admin
        end

        it 'redirects to the sign in page' do
          post polymorphic_path(work_class), params: { work_type => valid_attributes }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'PATCH /update' do
      context 'with valid parameters' do
        it 'updates the provided attributes and redirects to the work' do
          patch polymorphic_path(work), params: { work_type => { title: ['A brand new title'] } }
          expect(response).to redirect_to(polymorphic_path(work))
          follow_redirect!
          expect(page).to have_css('.work-title-wrapper h1', text: 'A brand new title')
        end
      end

      context 'with invalid parameters' do
        it 're-renders the edit work form with an error', :aggregate_failures do
          patch polymorphic_path(work), params: { work_type => invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(page).to have_css('div.alert-danger[role="alert"]', text: 'Title your work must have a title.')

          form = page.find('form')
          expect(form['id']).to eq("edit_#{work_type}_#{work.id}")

          expect(work.reload.title).to eq ['A test title']
        end
      end

      context 'with an unauthenticated user' do
        before do
          sign_out admin
        end

        it 'redirects to the sign in page' do
          patch polymorphic_path(work), params: { work_type => { title: ['A brand new title'] } }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'DELETE /destroy', :aggregate_failures do
      it 'destroys the requested work' do
        id = work.id # ensures the work exists before attempting to delete it
        expect {
          delete polymorphic_path(work)
        }.to change(work_class, :count).by(-1)
        expect(response).to redirect_to(hyrax.my_works_path)
        expect { work_class.find(id) }.to raise_error(Ldp::Gone)
      end

      context 'with an unauthenticated user' do
        before do
          sign_out admin
        end

        it 'redirects to the sign in page' do
          delete polymorphic_path(work)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
