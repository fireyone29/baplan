require 'rails_helper'

RSpec.describe 'home/index.html.erb', type: :view do
  it 'has a link to the about page' do
    render
    assert_select 'a[href=?]', about_path
  end

  it 'has a link to the signup' do
    render
    assert_select 'a[href=?]', new_user_registration_path
  end

  it 'has a link to the login' do
    render
    assert_select 'a[href=?]', new_user_session_path
  end
end
