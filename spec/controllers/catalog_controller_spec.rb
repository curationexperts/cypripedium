# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController do
  let(:controller) { described_class.new }
  # ensure we turn off bookmark controls in all views, e.g. blacklight gallery
  # see https://github.com/projectblacklight/blacklight/blob/v6.25.0/app/controllers/concerns/blacklight/default_component_configuration.rb#L7
  it 'disables bookmark controls' do
    expect(controller.render_bookmarks_control?).to be_falsey
  end
end
