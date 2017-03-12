require 'rails_helper'

RSpec.describe 'goals/new', type: :view do
  before(:each) do
    assign(:goal, FactoryGirl.build(:goal))
  end

  it 'renders new goal form' do
    render

    assert_select 'form[action=?][method=?]', goals_path, 'post' do
      assert_select 'input#goal_description[name=?]', 'goal[description]'
      assert_select 'select#goal_frequency[name=?]', 'goal[frequency]'
      assert_select 'input[type=submit][value=?]', 'Create Goal'
    end
  end

  it 'renders a cancel button' do
    render
    assert_select 'form[action=?][method=?]', goals_path, 'post' do
      assert_select 'a[role=?][href=?]', 'button', 'javascript:history.back()',
                    text: 'Cancel'
    end
  end

  it_behaves_like 'displays goal form errors', [:description, :frequency]
end
