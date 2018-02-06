require 'rails_helper'

describe 'WorkZip routes:', type: :routing do
  it 'a route to download the zip file for a work' do
    expect(get: 'zip/123').to route_to(
      controller: 'work_zips',
      action: 'download',
      work_id: '123'
    )
  end

  it 'has a named route to download a zip' do
    expect(get: download_zip_path('123')).to route_to(
      controller: 'work_zips',
      action: 'download',
      work_id: '123'
    )
  end

  it 'a route to create a new WorkZip' do
    expect(post: 'zip/123').to route_to(
      controller: 'work_zips',
      action: 'create',
      work_id: '123'
    )
  end

  it 'has a named route to create a new zip' do
    expect(post: create_zip_path('123')).to route_to(
      controller: 'work_zips',
      action: 'create',
      work_id: '123'
    )
  end
end
