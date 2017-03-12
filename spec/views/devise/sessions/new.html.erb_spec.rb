require 'rails_helper'
include DeviseHelpers

RSpec.describe 'devise/sessions/new', type: :view do
  it 'renders new registration form' do
    render

    assert_select 'form[action=?][method=?]', user_session_path, 'post' do
      assert_select 'input#user_email[name=?]', 'user[email]'
      assert_select 'input#user_password[name=?]', 'user[password]'
      assert_select 'input#user_remember_me[name=?]', 'user[remember_me]'
      assert_select 'input[type=submit][value=?]', 'Login'
    end
  end

  it_behaves_like 'displays devise form errors', [:email, :password]
end
