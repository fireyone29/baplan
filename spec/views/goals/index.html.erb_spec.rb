require 'rails_helper'

RSpec.shared_examples 'has basic controls' do
  it 'renders the Add Goal button' do
    render
    assert_select 'h1>a[role=?][href=?]', 'button', new_goal_path,
                  text: 'Add Goal'
  end
end

RSpec.describe 'goals/index', type: :view do
  let(:description) { 'Description' }
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

  context 'without goals' do
    before do
      assign(:goals, [])
    end

    it 'renders a friendly header' do
      render
      assert_select 'h1', text: /My Goals/
    end

    it 'lets you know you have no goals yet' do
      render
      assert_select 'p.empty', text: /You have no goals. Try adding one/
    end

    it 'links to the about page' do
      render
      assert_select 'a[href=?]', about_path, text: 'learn more'
    end

    it_behaves_like 'has basic controls'
  end

  context 'with one goal' do
    before do
      assign(:goals, [goal1])
    end

    it 'renders the goal' do
      render
      assert_select 'div.panel-group>div.panel' do
        assert_select 'div.panel-heading>h4.panel-title' do
          assert_select 'a', count: 1, text: /daily/
          assert_select 'a', count: 1, text: /#{description}/
        end
      end
    end

    it_behaves_like 'has dropdown with many goal actions' do
      let(:goal) { goal1 }
    end

    it_behaves_like 'has basic controls'
  end

  context 'with multiple goals' do
    before do
      assign(:goals, [goal1, goal2])
    end

    it 'renders a list of goals' do
      render
      assert_select 'div.panel-group>div.panel' do
        assert_select 'div.panel-heading>h4.panel-title' do
          assert_select 'a', count: 2, text: /daily/
          assert_select 'a', count: 2, text: /#{description}/
        end
      end
    end

    it_behaves_like 'has dropdown with many goal actions' do
      let(:goal) { goal1 }
    end

    it_behaves_like 'has dropdown with many goal actions' do
      let(:goal) { goal2 }
    end

    it_behaves_like 'has basic controls'
  end
end
