require 'rails_helper'
include DeviseHelpers

RSpec.describe 'devise/confirmations/new', type: :view do
  it 'renders new registration form' do
    render

    assert_select 'form[action=?][method=?]', user_confirmation_path, 'post' do
      assert_select 'input#user_email[name=?]', 'user[email]'
      assert_select 'input[type=submit][value=?]', 'Resend confirmation'
    end
  end

  it_behaves_like 'displays devise form errors', [:email]
end
