require 'rails_helper'

RSpec.describe Goal, type: :model do
  it 'must be associated with a user' do
    expect(FactoryGirl.build(:goal, user_id: nil)).not_to be_valid
  end

  it 'only allows valid frequencies' do
    expect{FactoryGirl.build(:goal, frequency: -1)}.to raise_error(ArgumentError)
  end

  it 'does not allow empty descriptions' do
    expect(FactoryGirl.build(:goal, description: '')).not_to be_valid
  end

  context 'with an existing goal' do
    let!(:goal) { FactoryGirl.create(:goal) }

    it 'does not allow duplicate descriptions for the same user' do
      expect(
        FactoryGirl.build(:goal, user_id: goal.user.id, description: goal.description)
      ).not_to be_valid
    end

    it 'allows the same description on different users' do
      expect(FactoryGirl.create(:goal, description: goal.description)).to be_valid
    end
  end

  context 'with associated streaks' do
    let(:goal) { FactoryGirl.create(:goal) }
    let!(:streak1) { FactoryGirl.create(:streak, goal_id: goal.id) }
    let!(:streak2) { FactoryGirl.create(:streak, goal_id: goal.id) }

    it 'destroys owned streaks when destroyed' do
      expect{goal.destroy}.to change(Streak, :count).by(-2)
      expect{streak1.reload}.to raise_error ActiveRecord::RecordNotFound
      expect{streak2.reload}.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
