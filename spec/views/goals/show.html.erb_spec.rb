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

  it "renders a back button" do
    render
    assert_select "a[type=button][href=?]", goals_path, text: "Back"
  end

  it_behaves_like 'has dropdown with many goal actions'
end
