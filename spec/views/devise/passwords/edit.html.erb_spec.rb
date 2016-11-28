require 'rails_helper'
include DeviseHelpers

RSpec.describe "devise/passwords/edit", type: :view do
  it "renders new registration form" do
    render

    assert_select "form[action=?][method=?]", user_password_path, "post" do
      assert_select "input#user_password[name=?]", "user[password]"
      assert_select "input#user_password_confirmation[name=?]", "user[password_confirmation]"
      assert_select "input[type=submit][value=?]", "Change my password"
    end
  end

  it_behaves_like "displays devise form errors", [:password, :password_confirmation]
end
