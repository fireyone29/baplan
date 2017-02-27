require 'rails_helper'

RSpec.describe "goals/show", type: :view do
  let(:goal) {
    FactoryGirl.create(:goal,
                       description: 'Description',
                       frequency: 0)
  }

  before(:each) do
    assign(:goal, goal)
  end

  it "renders attributes in the jumbotron" do
    render
    assert_select "div.jumbotron" do
      assert_select "h1", text: /#{goal.description}/
      assert_select "h1", text: /#{goal.frequency}/
    end
  end

  it "renders a delete button" do
    render
    assert_select "a[type=button][href=?][data-method=?]", goal_path(goal), "delete",
                  text: "Delete"
  end

  it "renders an edit button" do
    render
    assert_select "a[type=button][href=?]", edit_goal_path(goal), text: "Edit"
  end

  it "renders a back button" do
    render
    assert_select "a[type=button][href=?]", goals_path, text: "Back"
  end

  it "renders an execute button" do
    render
    assert_select "a[type=button][href=?]", goal_streaks_execute_path(goal),
                  text: "Execute"
  end

  it "renders an unexecute button" do
    render
    assert_select "a[type=button][href=?]", goal_streaks_unexecute_path(goal),
                  text: "Unexecute"
  end
end
