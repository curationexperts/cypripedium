# frozen_string_literal: true
RSpec.shared_examples 'a work with additional metadata' do
  let(:multivalued) { ['A string for testing multivalued values.'] }
  it 'has an abstract' do
    work.abstract = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/abstract/)
    expect(work.abstract).to eq(multivalued)
  end

  it 'has an alternative title' do
    work.alternative_title = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/alternative/)
    expect(work.alternative_title).to eq(multivalued)
  end

  it 'has a bibliographic citation' do
    work.bibliographic_citation = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/bibliographicCitation/)
    expect(work.bibliographic_citation).to eq(multivalued)
  end

  it 'has a corporate name' do
    work.corporate_name = multivalued
    expect(work.resource.dump(:ttl)).to match(/loc.gov\/mads\/rdf\/v1#CorporateName/)
    expect(work.corporate_name).to eq(multivalued)
  end

  it 'has a date available' do
    work.date_available = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/available/)
    expect(work.date_available).to eq(multivalued)
  end

  it 'has an extent' do
    work.extent = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/extent/)
    expect(work.extent).to eq(multivalued)
  end

  it 'has a part' do
    work.has_part = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/hasPart/)
    expect(work.has_part).to eq(multivalued)
  end

  it 'has is version of' do
    work.is_version_of = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/isVersionOf/)
    expect(work.is_version_of).to eq(multivalued)
  end

  it 'has has version of' do
    work.has_version = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/hasVersion/)
    expect(work.has_version).to eq(multivalued)
  end

  it 'has isReplacedBy' do
    work.is_replaced_by = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/isReplacedBy/)
    expect(work.is_replaced_by).to eq(multivalued)
  end

  it 'has replaces' do
    work.replaces = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/replaces/)
    expect(work.replaces).to eq(multivalued)
  end

  it 'has requires' do
    work.requires = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/requires/)
    expect(work.requires).to eq(multivalued)
  end

  it 'has spatial' do
    work.geographic_name = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/spatial/)
    expect(work.geographic_name).to eq(multivalued)
  end

  it 'has table of contents' do
    work.table_of_contents = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/tableOfContents/)
    expect(work.table_of_contents).to eq(multivalued)
  end

  it 'has temporal' do
    work.temporal = multivalued
    expect(work.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/temporal/)
    expect(work.temporal).to eq(multivalued)
  end
end
