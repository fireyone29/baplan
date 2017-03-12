require 'rails_helper'

RSpec.shared_examples 'a streak' do |factory|
  let(:today) { Time.zone.today }
  it 'must be associated with a gaol' do
    expect(FactoryGirl.build(factory, goal_id: nil)).not_to be_valid
  end

  it 'rejects negative streaks' do
    params = { start_date: today, end_date: today - 1 }
    expect(FactoryGirl.build(factory, params)).not_to be_valid
  end

  it 'allows same day streaks' do
    params = { start_date: today, end_date: today }
    expect(FactoryGirl.build(factory, params)).to be_valid
  end

  describe '#length' do
    let(:params) { { start_date: today - diff, end_date: today } }
    let(:streak) { FactoryGirl.build(factory, params)}

    context 'with start after end' do
      let(:diff) { 3 }
      it 'calculates inclusive duration' do
        expect(streak.length).to eql((diff + 1).days)
      end
    end

    context 'with the same start and end' do
      let(:diff) { 0 }
      it 'equals one' do
        expect(streak.length).to eql 1.day
      end
    end
  end

  describe 'goal longest streak updates' do
    let!(:goal) { FactoryGirl.create(:goal) }

    context 'when creating first streak' do
      it 'sets longest streak' do
        expect(goal.longest_streak_length).to eq 0
        streak = FactoryGirl.create(factory, goal_id: goal.id)
        expect(goal.reload.longest_streak_length).to eq streak.length
      end
    end

    context 'when updating a streak that is not the longest' do
      let!(:longest_streak) {
        FactoryGirl.create(factory,
                           goal_id: goal.id,
                           start_date: 3.years.ago,
                           end_date: 1.year.ago)
      }

      it 'does not change longest streak' do
        expect(goal.reload.longest_streak_length).to eq longest_streak.length
        FactoryGirl.create(factory,
                           goal_id: goal.id,
                           start_date: 5.days.ago,
                           end_date: 2.days.ago)
        expect(goal.reload.longest_streak_length).to eq longest_streak.length
      end
    end

    context 'when updating a streak that is the longest' do
      let!(:streak) {
        FactoryGirl.create(factory,
                           goal_id: goal.id,
                           start_date: today - length + 1.day,
                           end_date: today)
      }
      let(:length) { 25.days }
      let(:change) { 4.days }

      context 'when increasing length' do
        it 'increases the longest streak length' do
          expect(goal.reload.longest_streak_length).to eq length
          streak.end_date = today + change
          streak.save!
          expect(goal.reload.longest_streak_length).to eq(length + change)
        end
      end

      context 'when descreasing length' do
        it 'decreases the longest streak length' do
          expect(goal.reload.longest_streak_length).to eq length
          streak.end_date = today - change
          streak.save!
          expect(goal.reload.longest_streak_length).to eq(length - change)
        end

        context 'when it no longer the longest' do
          let!(:streak2) {
            FactoryGirl.create(factory,
                               goal_id: goal.id,
                               start_date: today - length + 2.days,
                               end_date: today)
          }

          it 'does not decrease the longest streak length' do
            expect(goal.reload.longest_streak_length).to eq length
            streak.end_date = today - change
            streak.save!
            expect(goal.reload.longest_streak_length).to eq streak2.length
          end
        end
      end
    end
  end
end

RSpec.shared_examples 'non-abstract streak' do |factory|
  let(:streak) {
    FactoryGirl.build(factory,
                      end_date: end_date,
                      start_date: end_date - 3.days)
  }

  describe '#recent?' do
    subject { streak.recent? }

    context 'without a recent end_date' do
      let(:end_date) { Time.zone.today - described_class.period * 2 }

      it { is_expected.to be false }
    end

    context 'with a recent end_date' do
      let(:end_date) { Time.zone.today - described_class.period }

      it { is_expected.to be true }
    end
  end

  describe '#current?' do
    subject { streak.current? }

    context 'without a current end_date' do
      let(:end_date) { Time.zone.today - described_class.period }

      it { is_expected.to be false }
    end

    context 'with a current end_date' do
      let(:end_date) { Time.zone.today + 1.day }

      it { is_expected.to be true }
    end
  end
end

RSpec.shared_examples 'mergeable streak' do
  let!(:start_date) { streak.start_date }
  let!(:end_date) { streak.end_date }

  context 'with other type of streak' do
    let(:other_streak) { FactoryGirl.create(:streak) }
    it 'raises a merge error' do
      expect{streak.merge!(other_streak)}.to raise_error(Streak::UpdateError)
    end
  end

  context 'with mergeable streaks' do
    it 'saves updates to start' do
      streak.merge!(before_streak)
      streak.reload
      expect(streak.start_date).to eql before_streak.start_date
      expect(streak.end_date).to eql end_date
    end

    it 'saves updates to end' do
      streak.merge!(after_streak)
      streak.reload
      expect(streak.end_date).to eql after_streak.end_date
      expect(streak.start_date).to eql start_date
    end

    it 'destroys the other streak' do
      streak.merge!(after_streak)
      expect{after_streak.reload}.to raise_error ActiveRecord::RecordNotFound
    end

    context 'with failures' do
      let(:error) { 'error!' }
      it 'does not destroy if save fails' do
        expect(streak).to receive(:save!).and_raise(error)
        expect{streak.merge!(after_streak)}.to raise_error(error)
        expect{after_streak.reload}.not_to raise_error
        expect(streak.reload.end_date).to eql end_date
      end

      it 'does not save if destroy fails' do
        expect(after_streak).to receive(:destroy!).and_raise(error)
        expect{streak.merge!(after_streak)}.to raise_error(error)
        expect{after_streak.reload}.not_to raise_error
        expect(streak.reload.end_date).to eql end_date
      end
    end
  end

  context 'with disjoint streaks' do
    it 'rejects unmergeable combinations' do
      expect{streak.merge!(disjoint_streak)}.to raise_error(Streak::UpdateError)
      expect{disjoint_streak.reload}.not_to raise_error
      expect(streak.reload.start_date).to eql start_date
    end

    it 'allows execution of one day in between' do
      streak.merge!(disjoint_streak, and_execute: true)
      streak.reload
      expect(streak.start_date).to eql disjoint_streak.start_date
      expect(streak.end_date).to eql end_date
    end
  end
end

RSpec.shared_examples 'splitable streak' do
  let!(:start_date) { streak.start_date }
  let!(:end_date) { streak.end_date }

  context 'with date outside the streak' do
    it 'rejects days before' do
      expect{streak.split!(streak.start_date - 2.days)}
        .to raise_error(Streak::UpdateError)
    end

    it 'rejects days after' do
      expect{streak.split!(streak.end_date + 2.days)}
        .to raise_error(Streak::UpdateError)
    end
  end

  context 'with date on the edge of the streak' do
    subject { streak.split!(start_date) }

    it 'unexecutes the date' do
      expect(streak).to receive(:unexecute!).with(start_date).and_call_original
      expect{subject}.not_to change{Streak.count}
      expect(subject).to eql nil
    end
  end

  context 'with date within the streak' do
    subject { streak.split!(date) }

    it 'creates a new streak' do
      expect{subject}.to change{Streak.count}.by(1)
    end

    it 'updates the streak appropriately' do
      subject
      expect(streak.reload.end_date).to eql end_date
      # TODO: test what it should be?
      expect(streak.reload.start_date).not_to eql start_date
    end

    it 'has two streaks with the correct information' do
      subject
      streaks = Streak.order('start_date')
      expect(streaks.count).to eql 2
      expect(streaks.first.start_date).to eql start_date
      # TODO: end_date?!?!?
      # TODO: start_date?!?!?!
      expect(streaks.last.end_date).to eql end_date
    end

    it 'returns the new streak' do
      expect(subject).to be_a Streak
      expect(subject).not_to be streak
      expect(subject.goal_id).to eql streak.goal_id
    end

    context 'with failures' do
      let(:error) { 'error!' }

      it 'does not update old streak if create fails' do
        expect(streak.class).to receive(:create!).and_raise(error)
        expect{subject}.to raise_error(error)
        expect(streak.reload.end_date).to eql end_date
        expect(streak.reload.start_date).to eql start_date
      end

      it 'does not create if update old streak fails' do
        expect(streak).to receive(:save!).and_raise(error)
        expect{subject}.to raise_error(error)
        expect(Streak.count).to eql 1 # no new streak created
        expect(streak.reload.end_date).to eql end_date
        expect(streak.reload.start_date).to eql start_date
      end
    end
  end
end

RSpec.describe Streak, type: :model do
  it_behaves_like 'a streak', :streak

  describe '#execute' do
    it 'raises NotImplementedError' do
      expect{FactoryGirl.build(:streak).execute(Time.zone.today)}
        .to raise_error(NotImplementedError)
    end
  end

  describe '#unexecute' do
    it 'raises NotImplementedError' do
      expect{FactoryGirl.build(:streak).unexecute(Time.zone.today)}
        .to raise_error(NotImplementedError)
    end
  end

  describe '#merge!' do
    it 'raises NotImplementedError' do
      expect{FactoryGirl.build(:streak).merge!(FactoryGirl.build(:streak))}
        .to raise_error(NotImplementedError)
    end
  end

  describe '#split!' do
    it 'raises NotImplementedError' do
      expect{FactoryGirl.build(:streak).split!(Time.zone.today)}
        .to raise_error(NotImplementedError)
    end
  end
end

RSpec.describe DailyStreak, type: :model do
  it_behaves_like 'a streak', :daily_streak
  it_behaves_like 'non-abstract streak', :daily_streak

  describe '#execute' do
    let!(:streak) { FactoryGirl.create(:daily_streak) }
    let(:start_date) { streak.start_date }
    let(:end_date) { streak.end_date }

    context 'with date within the streak' do
      let(:date) { seeded_rand(streak.start_date..streak.end_date) }

      it 'succeeds without updating the streak' do
        expect(streak.execute(date)).to be_truthy
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date outside the streak' do
      it 'rejects days before' do
        expect(streak.execute(streak.start_date - 5.days)).to be_falsey
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end

      it 'rejects days after' do
        expect(streak.execute(streak.end_date + 5.days)).to be_falsey
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date adjacent to the streak' do
      it 'saves updates to start' do
        expect(streak.execute(start_date - 1.day)).to be_truthy
        expect(streak.reload.start_date).to eql start_date - 1.day
      end

      it 'saves updates to end' do
        expect(streak.execute(end_date + 1.day)).to be_truthy
        expect(streak.reload.end_date).to eql end_date + 1.day
      end
    end
  end

  describe '#unexecute' do
    let!(:streak) { FactoryGirl.create(:daily_streak) }
    let(:start_date) { streak.start_date }
    let(:end_date) { streak.end_date }

    context 'with date inside the streak' do
      let(:date) {
        seeded_rand((streak.start_date + 1.day)..(streak.end_date - 1.day))
      }

      it 'fails without updating the streak' do
        expect(streak.unexecute(date)).to be_falsey
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date outside the streak' do
      it 'accepts days before without updating' do
        expect(streak.unexecute(streak.start_date - 5.days)).to be_truthy
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end

      it 'accepts days after without updating' do
        expect(streak.unexecute(streak.end_date + 5.days)).to be_truthy
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date at the edge of the streak' do
      it 'saves updates to start' do
        expect(streak.unexecute(start_date)).to be_truthy
        expect(streak.reload.start_date).to eql start_date + 1.day
      end

      it 'saves updates to end' do
        expect(streak.unexecute(end_date)).to be_truthy
        expect(streak.reload.end_date).to eql end_date - 1.day
      end
    end

    context 'when unexecuting the only remaining days' do
      let!(:streak) {
        FactoryGirl.create(:daily_streak,
                           start_date: Time.zone.today,
                           end_date: Time.zone.today)
      }

      it 'succeeds' do
        expect(streak.unexecute(end_date)).to be_truthy
      end

      it 'destroys the streak' do
        expect{streak.unexecute(start_date)}.to change{Streak.count}.by(-1)
        expect{streak.reload}.to raise_error ActiveRecord::RecordNotFound
      end

      it 'resets longest streak to zero' do
        expect(streak.goal.reload.longest_streak_length).to eq streak.length
        streak.unexecute(start_date)
        expect(streak.goal.reload.longest_streak_length).to eq 0
      end
    end
  end

  describe '#merge!' do
    let!(:streak) { FactoryGirl.create(:daily_streak) }
    let(:before_streak) {
      FactoryGirl.create(:daily_streak,
                         start_date: start_date - 5.days,
                         end_date: start_date - 1.day)
    }
    let(:after_streak) {
      FactoryGirl.create(:daily_streak,
                         start_date: end_date + 1.day,
                         end_date: end_date + 5.days)
    }
    let(:disjoint_streak) {
      FactoryGirl.create(:daily_streak,
                         start_date: start_date - 5.days,
                         end_date: start_date - 2.days)
    }

    it_behaves_like 'mergeable streak'
  end

  describe '#split!' do
    let!(:streak) { FactoryGirl.create(:daily_streak) }
    let(:date) {
      seeded_rand((streak.start_date + 1.day)..(streak.end_date - 1.day))
    }

    it_behaves_like 'splitable streak'
  end
end

RSpec.describe WeeklyStreak, type: :model do
  it_behaves_like 'a streak', :weekly_streak
  it_behaves_like 'non-abstract streak', :weekly_streak

  describe '#execute' do
    let!(:streak) { FactoryGirl.create(:weekly_streak) }
    let(:start_date) { streak.start_date }
    let(:end_date) { streak.end_date }

    context 'with date within the streak' do
      let(:date) { seeded_rand(streak.start_date..streak.end_date) }

      it 'succeeds without updating the streak' do
        expect(streak.execute(date)).to be_truthy
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date outside the streak' do
      it 'rejects days before' do
        expect(streak.execute(streak.start_date - 3.weeks)).to be_falsey
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end

      it 'rejects days after' do
        expect(streak.execute(streak.end_date + 3.weeks)).to be_falsey
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date adjacent to the streak' do
      context 'within the adjacent week' do
        it 'saves updates to start' do
          expect(streak.execute(start_date - 1.day)).to be_truthy
          expect(streak.reload.start_date).to eql start_date - 1.week
        end

        it 'saves updates to end' do
          expect(streak.execute(end_date + 1.day)).to be_truthy
          expect(streak.reload.end_date).to eql end_date + 1.week
        end
      end

      context 'at the far end of the adject week' do
        it 'saves updates to start' do
          expect(streak.execute(start_date - 1.week)).to be_truthy
          expect(streak.reload.start_date).to eql start_date - 1.week
        end

        it 'saves updates to end' do
          expect(streak.execute(end_date + 1.week)).to be_truthy
          expect(streak.reload.end_date).to eql end_date + 1.week
        end
      end
    end
  end

  describe '#unexecute' do
    let!(:streak) { FactoryGirl.create(:weekly_streak) }
    let(:start_date) { streak.start_date }
    let(:end_date) { streak.end_date }

    context 'with date inside the streak' do
      let(:date) {
        seeded_rand((streak.start_date + 1.week)..(streak.end_date - 1.week))
      }

      it 'fails without updating the streak' do
        expect(streak.unexecute(date)).to be_falsey
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date outside the streak' do
      it 'accepts days before without updating' do
        expect(streak.unexecute(streak.start_date - 3.weeks)).to be_truthy
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end

      it 'accepts days after without updating' do
        expect(streak.unexecute(streak.end_date + 3.weeks)).to be_truthy
        streak.reload
        expect(streak.start_date).to eql start_date
        expect(streak.end_date).to eql end_date
      end
    end

    context 'with date at the edge of the streak' do
      it 'saves updates to start' do
        expect(streak.unexecute(start_date)).to be_truthy
        expect(streak.reload.start_date).to eql start_date + 1.week
      end

      it 'saves updates to end' do
        expect(streak.unexecute(end_date)).to be_truthy
        expect(streak.reload.end_date).to eql end_date - 1.week
      end
    end

    context 'when unexecuting the only remaining days' do
      let!(:streak) {
        FactoryGirl.create(:weekly_streak,
                           start_date: Time.zone.today - 6.days,
                           end_date: Time.zone.today)
      }

      it 'succeeds' do
        expect(streak.unexecute(end_date)).to be_truthy
      end

      it 'destroys the streak' do
        expect{streak.unexecute(start_date)}.to change{Streak.count}.by(-1)
        expect{streak.reload}.to raise_error ActiveRecord::RecordNotFound
      end

      it 'resets longest streak to zero' do
        expect(streak.goal.reload.longest_streak_length).to eq streak.length
        streak.unexecute(start_date)
        expect(streak.goal.reload.longest_streak_length).to eq 0
      end
    end
  end

  describe '#merge!' do
    let!(:streak) { FactoryGirl.create(:weekly_streak) }
    let(:before_streak) {
      FactoryGirl.create(:weekly_streak,
                         start_date: start_date - 5.weeks,
                         end_date: start_date - 1.week)
    }
    let(:after_streak) {
      FactoryGirl.create(:weekly_streak,
                         start_date: end_date + 1.week,
                         end_date: end_date + 5.weeks)
    }
    let(:disjoint_streak) {
      FactoryGirl.create(:weekly_streak,
                         start_date: start_date - 5.weeks,
                         end_date: start_date - 2.weeks)
    }

    it_behaves_like 'mergeable streak'
  end

  describe '#split!' do
    let!(:streak) { FactoryGirl.create(:weekly_streak) }
    let(:date) {
      seeded_rand((streak.start_date + 1.week)..(streak.end_date - 1.week))
    }

    it_behaves_like 'splitable streak'
  end
end
