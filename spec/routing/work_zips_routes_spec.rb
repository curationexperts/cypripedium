require 'rails_helper'

describe 'WorkZip routes:', type: :routing do
  it 'a route to download the zip file for a work' do
    expect(get: 'zip/123').to route_to(
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
end
