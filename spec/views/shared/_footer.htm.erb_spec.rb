# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'shared/_footer.html.erb', type: :view do
  before do
    # clear memoized Release data
    ReleaseInfo.instance_variable_set(:@sha, nil)
    ReleaseInfo.instance_variable_set(:@branch, nil)
    allow(ReleaseInfo).to receive(:`).with(/git rev-parse HEAD/).and_return('my_fancy_commmit_sha')
    allow(ReleaseInfo).to receive(:`).with(/git rev-parse --abbrev-ref HEAD/).and_return('the_fancy_branch_name')
  end

  it 'includes the git branch and commit info' do
    render
    expect(rendered)
      .to have_selector('footer.site-footer//span[@title="my_fancy_commmit_sha"]',
                        text: /the_fancy_branch_name/)
  end
end
