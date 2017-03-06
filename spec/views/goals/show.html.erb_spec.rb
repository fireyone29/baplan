require 'rails_helper'

RSpec.describe "goals/show", type: :view do
  let(:goal) {
    FactoryGirl.create(:goal,
                       description: 'Description',
                       frequency: 0)
  }
  let(:length) { 10 }

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

  it "renders current streak" do
    expect_any_instance_of(GoalsHelper).to receive(:current_length)
                                            .with(goal).and_return(length)
    render
    assert_select "div.jumbotron" do
      assert_select "p", text: "Current streak #{length} days"
    end
  end

  it "renders longest streak" do
    expect(goal).to receive(:longest_streak_length).and_return(length.days)
    render
    assert_select "div.jumbotron" do
      assert_select "p", text: "Longest streak #{length} days"
    end
  end

  it "renders a back button" do
    render
    assert_select "a[type=button][href=?]", goals_path, text: "Back"
  end

  it_behaves_like 'has dropdown with many goal actions'
end
