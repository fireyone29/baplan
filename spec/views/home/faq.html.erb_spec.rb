require 'rails_helper'

RSpec.describe 'home/faq.html.erb', type: :view do
  it 'has a link to the about page' do
    render
    assert_select 'a[href=?]', about_path
  end
end
