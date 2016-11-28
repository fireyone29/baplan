RSpec.shared_examples "displays devise form errors" do |fields|
  let(:message) { 'my error message!' }

  fields.each do |field|
    context "error on #{field}" do
      before do
        resource.errors.add(field, message)
      end

      it 'highlights the field' do
        render
        assert_select "div[class=?]>input[name=?]", "field_with_errors", "user[#{field}]"
      end

      it 'displays the error message' do
        render
        assert_select "div[class=?]", "form-group" do
          assert_select "input[name=?]", "user[#{field}]"
          assert_select "div[class=?]>span", "field_with_errors", {text: /#{message}/i}
        end
      end

      it 'flashes proper error count' do
        render
        assert_select "div[class=?]", "alert alert-danger",
                      {text: /fix the 1 highlighted error/}
      end
    end
  end

  context "errors on all fields" do
    before do
      fields.each do |field|
        resource.errors.add(field, message)
      end
    end

    it 'flashes proper error count' do
      render
      assert_select "div[class=?]", "alert alert-danger",
                    {text: /fix the #{fields.count} highlighted error#{fields.count != 1 ? 's' : ''}/}
    end
  end
end
