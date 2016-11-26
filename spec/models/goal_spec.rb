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
end
