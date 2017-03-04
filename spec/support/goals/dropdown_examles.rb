RSpec.shared_examples 'has dropdown with many goal actions' do
  it 'renders a execute option' do
    render
    assert_select 'ul' do
      assert_select ":match('class', ?)", /dropdown-menu/
      assert_select 'li>a[href=?]', goal_streaks_execute_path(goal),
                    text: 'Execute'
    end
  end

  it 'renders a unexecute option' do
    render
    assert_select 'ul' do
      assert_select ":match('class', ?)", /dropdown-menu/
      assert_select 'li>a[href=?]', goal_streaks_unexecute_path(goal),
                    text: 'Unexecute'
    end
  end

  it 'renders a details option' do
    render
    assert_select 'ul' do
      assert_select ":match('class', ?)", /dropdown-menu/
      assert_select 'li>a[href=?]', goal_path(goal),
                    text: 'Details'
    end
  end

  it 'renders a edit option' do
    render
    assert_select 'ul' do
      assert_select ":match('class', ?)", /dropdown-menu/
      assert_select 'li>a[href=?]', edit_goal_path(goal),
                    text: 'Edit'
    end
  end

  it 'renders a delete option' do
    render
    assert_select 'ul' do
      assert_select ":match('class', ?)", /dropdown-menu/
      assert_select 'li>a>form[method=?][action=?]', 'post',  goal_path(goal) do
        assert_select 'input[name=?][value=?]', '_method', 'delete'
        assert_select 'button[data-confirm][type=?]', 'submit', text: 'Delete'
      end
    end
  end
end
