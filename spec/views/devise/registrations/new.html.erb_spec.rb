require 'rails_helper'
include DeviseHelpers

RSpec.describe 'devise/registrations/new', type: :view do
  it 'renders new registration form' do
    render

    assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
      assert_select 'input#user_email[name=?]', 'user[email]'
      assert_select 'input#user_password[name=?]', 'user[password]'
      assert_select 'input#user_password_confirmation[name=?]',
                    'user[password_confirmation]'
      assert_select 'input[type=submit][value=?]', 'Sign up'
    end
  end

  it_behaves_like 'displays devise form errors',
                  [:email, :password, :password_confirmation]
end
