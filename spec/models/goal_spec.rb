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

  describe '#latest_streak' do
    let(:goal) { FactoryGirl.create(:goal) }
    subject(:latest_streak) { goal.latest_streak }

    context 'with no streaks' do
      it 'returns nil' do
        expect(latest_streak).to eq nil
      end
    end

    context 'with multiple streaks' do
      let!(:streak1) { FactoryGirl.create(:streak,
                                          start_date: 5.days.ago,
                                          end_date: 1.day.ago,
                                          goal_id: goal.id)
      }
      let!(:streak2) { FactoryGirl.create(:streak,
                                          start_date: 1.year.ago,
                                          end_date: 1.week.ago,
                                          goal_id: goal.id)
      }

      it 'returns the streak with the most recent end_date' do
        expect(latest_streak).to eq streak1
      end
    end
  end

  describe '#relevant_streaks' do
    let!(:goal) { FactoryGirl.create(:goal) }
    let(:date) { Date.today }
    subject { goal.relevant_streaks(date) }

    context 'with no streaks' do
      it { is_expected.to be_empty }
    end

    context 'with streaks from other goals' do
      before do
        FactoryGirl.create(:daily_streak)
      end

      it { is_expected.to be_empty }
    end

    context 'with streaks not close to date' do
      let!(:streak) {
        FactoryGirl.create(:daily_streak,
                           goal_id: goal.id,
                           start_date: date - 1.year)
      }

      it { is_expected.to be_empty }
    end

    context 'weekly goal' do
      let(:goal) { FactoryGirl.create(:goal, frequency: :weekly) }

      context 'with date one period before streak' do
        let!(:streak) {
          FactoryGirl.create(:weekly_streak,
                             goal_id: goal.id,
                             start_date: date + 3.days)
        }
        it 'returns that streak' do
          expect(subject).to match_array [streak]
        end
      end

      context 'with date one period after streak' do
        let!(:streak) {
          FactoryGirl.create(:weekly_streak,
                             goal_id: goal.id,
                             start_date: date - 17.days,
                             end_date: date - 3.days)
        }
        it 'returns that streak' do
          expect(subject).to match_array [streak]
        end
      end
    end

    context 'daily goal' do
      let(:goal) { FactoryGirl.create(:goal, frequency: :daily) }

      context 'with date one period before streak' do
        let!(:streak) {
          FactoryGirl.create(:daily_streak,
                             goal_id: goal.id,
                             start_date: date + 1.day)
        }
        it 'returns that streak' do
          expect(subject).to match_array [streak]
        end
      end

      context 'with date one period after streak' do
        let!(:streak) {
          FactoryGirl.create(:daily_streak,
                             goal_id: goal.id,
                             start_date: date - 5.days,
                             end_date: date - 1.day)
        }
        it 'returns that streak' do
          expect(subject).to match_array [streak]
        end
      end
    end

    context 'with streak containing the date' do
      let!(:streak) {
        FactoryGirl.create(:daily_streak,
                           goal_id: goal.id,
                           start_date: date - 2.weeks,
                           end_date: date + 1.week)
      }
      it 'returns that streak' do
        expect(subject).to match_array [streak]
      end
    end

    context 'with two relevant steaks' do
      let(:goal) { FactoryGirl.create(:goal, frequency: :daily) }
      let!(:streak1) {
        FactoryGirl.create(:daily_streak,
                           goal_id: goal.id,
                           start_date: date - 5.days,
                           end_date: date - 1.day)
      }
      let!(:streak2) {
        FactoryGirl.create(:daily_streak,
                           goal_id: goal.id,
                           start_date: date + 1.day)
      }

      it 'returns both streaks' do
        expect(subject).to match_array [streak1, streak2]
      end
    end

    context 'with one relevant and one irrelevant streak' do
      let(:goal) { FactoryGirl.create(:goal, frequency: :daily) }
      let!(:streak1) {
        FactoryGirl.create(:daily_streak,
                           goal_id: goal.id,
                           start_date: date - 5.days,
                           end_date: date - 1.day)
      }
      let!(:streak2) {
        FactoryGirl.create(:daily_streak,
                           goal_id: goal.id,
                           start_date: date + 1.year)
      }
      it 'returns the relevant streak' do
        expect(subject).to match_array [streak1]
      end
    end

    # TODO: I don't have any idea how this should work even in theory
    context 'with streak type not matching goal frequency' do
      it 'should something...'
    end
  end

  describe '#update_or_create' do
    let(:date) { Date.today }
    let!(:goal) { FactoryGirl.create(:goal, frequency: :weekly) }
    subject { goal.update_or_create!(date) }

    context 'with no relevant streaks' do
      it 'creates a new streak of the correct type' do
        expect{subject}.to change{WeeklyStreak.count}.by(1)
      end

      it 'has the correct start and end date' do
        subject
        streak = Streak.last
        expect(streak.start_date).to eql date
        expect(streak.length).to eql 1.week
      end

      context 'with streak length greater than goal longest streak' do
        it 'updates goal longest streak' do
          subject
          streak = Streak.last
          expect(goal.reload.longest_streak_length).to eq streak.length
        end
      end
    end

    context 'with one relevant streak' do
      let(:streak) { FactoryGirl.create(:daily_streak, goal_id: goal.id) }
      let(:date) { streak.end_date }
      let(:streak_length) { 0 }

      before do
        allow_any_instance_of(Streak).to receive(:length).and_return(streak_length)
        expect(goal).to receive(:relevant_streaks).with(date).and_return([streak])
      end

       it 'executes the date on that streak' do
        expect(streak).to receive(:execute!).with(date)
        subject
      end

      context 'with streak length greater than goal longest streak' do
        let(:streak_length) { goal.longest_streak_length + 5.days.seconds }

        it 'updates goal longest streak' do
          subject
          expect(goal.reload.longest_streak_length).to eq streak_length
        end
      end
    end

    context 'with two relevant streaks' do
      let(:streak1) { FactoryGirl.create(:daily_streak, goal_id: goal.id) }
      let(:streak2) { FactoryGirl.create(:daily_streak, goal_id: goal.id,
                                         start_date: streak1.end_date) }
      let(:streak_length) { 0 }

      before do
        allow_any_instance_of(Streak).to receive(:length).and_return(streak_length)
        expect(goal).to receive(:relevant_streaks).with(date).and_return([streak1, streak2])
      end

      it 'it merges the streaks' do
        expect(streak1).to receive(:merge!).with(streak2, and_execute: true)
        subject
      end

      context 'with streak length greater than goal longest streak' do
        let(:streak_length) { goal.longest_streak_length + 5.days.seconds }

        it 'updates goal longest streak' do
          expect(streak1).to receive(:merge!).with(streak2, and_execute: true)
          subject
          expect(goal.reload.longest_streak_length).to eq streak_length
        end
      end
    end
  end
end
