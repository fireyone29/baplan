require 'rails_helper'
include DeviseHelpers

RSpec.describe "devise/registrations/edit", type: :view do
  it "renders the account settings form" do
    render

    assert_select "form[action=?][method=?]", user_registration_path, "post" do
      # email field should be pre-filled with the current email
      assert_select "input#user_email[name=?]", "user[email]", {text: resource.email}
      assert_select "input#user_password[name=?]", "user[password]"
      assert_select "input#user_password_confirmation[name=?]", "user[password_confirmation]"
      assert_select "input#user_current_password[name=?]", "user[current_password]"
      assert_select "input[type=submit][value=?]", "Update"
    end
  end

  it_behaves_like "displays devise form errors",
                  [:email, :password, :password_confirmation,
                   :current_password]

  it "renders the delete account form" do
    render

    assert_select "form[action=?][method=?]", user_registration_path, "post" do
      assert_select "input[name=_method][value=delete]"
      assert_select "input[type=submit][value=?]", "Delete my account"
    end
  end
end
