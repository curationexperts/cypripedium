# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Creator, type: :model do
  it "has a ID" do
    creator = described_class.create
    expect(creator.id).not_to be nil
  end
end
