require 'rails_helper'

RSpec.shared_examples "has basic controls" do
  it "renders the Add Goal button" do
    render
    assert_select "h1>a[role=?][href=?]", "button", new_goal_path, text: "Add Goal"
  end
end

RSpec.describe "goals/index", type: :view do
  let(:description) { "Description" }
  let(:goal1) {
    FactoryGirl.create(:goal,
                       description: description,
                       frequency: 0)
  }
  let(:goal2) {
    FactoryGirl.create(:goal,
                       description: description,
                       frequency: 0)
  }

  context "without goals" do
    before do
      assign(:goals, [])
    end

    it "renders a friendly header" do
      render
      assert_select "h1", text: /My Goals/
    end

    it "lets you know you have no goals yet" do
      render
      assert_select "p.empty", text: "You have no goals. Try adding one."
    end

    it_behaves_like "has basic controls"
  end

  context "with one goal" do
    before do
      assign(:goals, [goal1])
    end

    it "renders the goal" do
      render
      assert_select "div.list-group" do
        assert_select "a.list-group-item > h3.list-group-item-heading",
                      text: /#{description}/, count: 1
        assert_select "a.list-group-item > h3.list-group-item-heading",
                      text: /daily/, count: 1
      end
    end

    it "renders a link to details" do
      render
      assert_select "div.list-group" do
        assert_select "a.list-group-item[href=?]", goal_path(goal1)
      end
    end

    it_behaves_like "has basic controls"
  end

  context "with multiple goals" do
    before do
      assign(:goals, [goal1, goal2])
    end

    it "renders a list of goals" do
      render
      assert_select "div.list-group" do
        assert_select "h3.list-group-item-heading", text: /#{description}/, count: 2
        assert_select "h3.list-group-item-heading", text: /daily/, count: 2
      end
    end

    it "renders links to details on entries" do
     render
      assert_select "div.list-group" do
        assert_select "a.list-group-item[href=?]", goal_path(goal1)
        assert_select "a.list-group-item[href=?]", goal_path(goal2)
      end
    end

    it_behaves_like "has basic controls"
  end
end
