require 'rails_helper'

RSpec.describe "goals/show", type: :view do
  before(:each) do
    @goal = assign(:goal, FactoryGirl.create(:goal,
                                             description: 'Description',
                                             frequency: 0))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/daily/)
  end
end
