require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  context 'with dependent goal' do
    let!(:goal) { FactoryBot.create(:goal, user_id: user.id) }

    it 'destroys owned goal when destroyed' do
      expect{user.destroy}.to change(Goal, :count).by(-1)
      expect{goal.reload}.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
