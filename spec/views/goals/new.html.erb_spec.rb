require 'rails_helper'

RSpec.describe "goals/new", type: :view do
  before(:each) do
    assign(:goal, FactoryGirl.build(:goal))
  end

  it "renders new goal form" do
    render

    assert_select "form[action=?][method=?]", goals_path, "post" do
      assert_select "input#goal_description[name=?]", "goal[description]"
      assert_select "select#goal_frequency[name=?]", "goal[frequency]"
    end
  end
end
