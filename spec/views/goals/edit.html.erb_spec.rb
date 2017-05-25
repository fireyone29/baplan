require 'rails_helper'

RSpec.describe 'goals/edit', type: :view do
  before(:each) do
    @goal = assign(:goal, FactoryGirl.create(:goal))
  end

  it 'renders the edit goal form' do
    render

    assert_select 'form[action=?][method=?]', goal_path(@goal), 'post' do
      assert_select 'input#goal_description[name=?][value=?]',
                    'goal[description]', @goal.description
      assert_select 'select#goal_frequency[name=?]', 'goal[frequency]'
      assert_select 'input[type=submit][value=?]', 'Update Goal'
    end
  end

  it 'renders a cancel button' do
    render
    assert_select 'form[action=?][method=?]', goal_path(@goal), 'post' do
      assert_select 'a[role=?][href=?]', 'button', 'javascript:history.back()',
                    text: 'Cancel'
    end
  end

  it_behaves_like 'displays goal form errors', %i[description frequency]
end
