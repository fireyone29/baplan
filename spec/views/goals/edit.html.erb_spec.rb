require 'rails_helper'

RSpec.describe "goals/edit", type: :view do
  before(:each) do
    @goal = assign(:goal, FactoryGirl.create(:goal))
  end

  it "renders the edit goal form" do
    render

    assert_select "form[action=?][method=?]", goal_path(@goal), "post" do
      assert_select "input#goal_description[name=?]", "goal[description]"
      assert_select "select#goal_frequency[name=?]", "goal[frequency]"
    end
  end
end
