require 'rails_helper'

RSpec.describe 'streaks/unexecute_form', type: :view do
  let(:action) { goal_unexecute_path(@goal) }
  before(:each) do
    @goal = assign(:goal, FactoryGirl.create(:goal))
  end

  it 'renders the unexecute form' do
    render

    assert_select 'form[action=?][method=?]', action, 'post' do
      assert_select 'label[for=?]', 'streak_date', text: 'Date'
      assert_select 'select[name=?]', 'date[year]'
      assert_select 'select[name=?]', 'date[month]'
      assert_select 'select[name=?]', 'date[day]'
      assert_select 'input[type=submit][value=?]', 'Save Streak'
    end
  end

  it 'renders a cancel button' do
    render
    assert_select 'form[action=?][method=?]', action, 'post' do
      assert_select 'a[role=?][href=?]', 'button', 'javascript:history.back()',
                    text: 'Cancel'
    end
  end
end
