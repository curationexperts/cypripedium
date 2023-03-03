# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserCollection, type: :model do
  before do
    I18n.locale = 'en'
  end
  it "has a ID" do
    user_collection = described_class.create(email: "test@test.com", collections: ['collection1', 'collection2'])
    expect(user_collection.id).not_to be nil
    expect(user_collection.email).to eq "test@test.com"
    expect(user_collection.collections).to eq ['collection1', 'collection2']
  end
  it "doesn't allow an empty email" do
    expect do
      described_class.create!(collections: ['collection1', 'collection2'])
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Email can't be blank, Email is invalid/)
  end
  it "doesn't allow a blank email" do
    expect do
      described_class.create!(email: "", collections: ['collection1', 'collection2'])
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Email can't be blank, Email is invalid/)
  end
  it "doesn't allow an invalid email" do
    expect do
      described_class.create!(email: "test123@123", collections: ['collection1', 'collection2'])
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Email is invalid/)
  end
  it "doesn't allow an empty collections" do
    expect do
      described_class.create!(email: "test123@test.com")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Collections can't be blank/)
  end
  it "doesn't allow a blank collections" do
    expect do
      described_class.create!(email: "test123@test.com", collections: [])
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Collections can't be blank/)
  end
  it "doesn't allow an invalid collections" do
    expect do
      described_class.create!(email: "test123@123", collections: 'collection1')
    end.to raise_error(ActiveRecord::SerializationTypeMismatch, /can't serialize `collections`: was supposed to be a Array, but was a String. -- "collection1"/)
  end
end
