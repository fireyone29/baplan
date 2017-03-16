require 'rails_helper'

RSpec.describe 'home/about.html.erb', type: :view do
  it 'has a link to the faq page' do
    render
    assert_select 'a[href=?]', faq_path
  end
end
