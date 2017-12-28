RSpec.shared_examples 'displays goal form errors' do |fields|
  let(:message) { 'my error message!' }
  let(:goal) {
    FactoryBot.create(:goal,
                      description: 'Description',
                      frequency: 0)
  }

  before(:each) do
    assign(:goal, goal)
  end

  fields.each do |field|
    context "error on #{field}" do
      before do
        goal.errors.add(field, message)
      end

      it 'highlights the field' do
        render
        assert_select 'div[class=?]', 'field_with_errors' do
          assert_select '[name=?]', "goal[#{field}]"
        end
      end

      it 'displays the error message' do
        render
        assert_select 'div[class=?]', 'form-group' do
          assert_select '[name=?]', "goal[#{field}]"
          assert_select 'div[class=?]>span', 'field_with_errors',
                        text: /#{message}/i
        end
      end

      it 'flashes proper error count' do
        render
        assert_select 'div[class=?]', 'alert alert-danger',
                      text: /fix the 1 highlighted error/ do
          assert_select 'button[data-dismiss=?]', 'alert'
        end
      end
    end
  end

  context 'errors on all fields' do
    let(:errors) { "error#{fields.count != 1 ? 's' : ''}" }
    before do
      fields.each do |field|
        goal.errors.add(field, message)
      end
    end

    it 'flashes proper error count' do
      render
      assert_select 'div[class=?]', 'alert alert-danger',
                    text: /fix the #{fields.count} highlighted #{errors}/ do
        assert_select 'button[data-dismiss=?]', 'alert'
      end
    end
  end
end
