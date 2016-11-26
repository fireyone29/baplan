require 'rails_helper'

RSpec.describe "goals/index", type: :view do
  before(:each) do
    assign(:goals, [
      FactoryGirl.create(:goal,
        :description => "Description",
        :frequency => 0
      ),
      FactoryGirl.create(:goal,
        :description => "Description",
        :frequency => 0
      )
    ])
  end

  it "renders a list of goals" do
    render
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "daily".to_s, :count => 2
  end
end
