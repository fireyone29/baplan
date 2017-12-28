require 'rails_helper'

RSpec.describe GoalsHelper, type: :helper do
  let(:goal) { FactoryBot.create(:goal) }
  let(:errors) { {} }

  before do
    allow(goal).to receive(:errors).and_return(errors)
    assign(:goal, goal)
  end

  describe '#goals_error_messages!' do
    subject { helper.goals_error_messages! }

    context 'when there are no errors' do
      let(:errors) { {} }

      it { is_expected.to be_empty }
    end

    context 'when there are errors' do
      let(:errors) { { first: :a, second: :b } }

      it 'renders the number of errors' do
        expect(subject).to include errors.count.to_s
      end
    end
  end

  describe '#goals_errors_for' do
    let(:field) { :a_field }
    subject { helper.goals_errors_for(field) }

    context 'when the field does not exist' do
      let(:errors) { {} }

      it { is_expected.to be_empty }
    end

    context 'when the field exists but has no error' do
      let(:errors) { { field => '' } }

      it { is_expected.to be_empty }
    end

    context 'when the field has an error' do
      let(:error_msgs) { ['oh no!', 'foobar'] }
      let(:errors) { { field => error_msgs } }

      it 'renders the error message' do
        expect(subject).to include error_msgs.first
        expect(subject).to include error_msgs.last
      end
    end
  end

  describe '#current_length' do
    subject { helper.current_length(goal) }

    context 'with no streak' do
      it { is_expected.to eq 0 }
    end

    context 'with a streak' do
      let(:streak) { FactoryBot.create(:daily_streak, goal_id: goal.id) }

      before do
        allow(goal).to receive(:latest_streak).and_return(streak)
        expect(streak).to receive(:recent?).and_return(recent)
      end

      context 'when streak is not recent' do
        let(:recent) { false }

        it { is_expected.to eq 0 }
      end

      context 'when streak is recent' do
        let(:recent) { true }

        it { is_expected.to eq streak.length / 1.day.seconds }
      end
    end
  end

  describe '#colors' do
    subject { helper.colors(goal) }

    context 'with streak' do
      let(:streak) { double('Streak') }
      let(:current) { false }
      let(:recent) { false }

      before do
        expect(goal).to receive(:latest_streak)
                         .and_return(streak)
                         .at_most(3).times
        expect(streak).to receive(:current?).and_return(current)
        expect(streak).to receive(:recent?).and_return(recent).at_most(:once)
      end

      context 'with current streak' do
        let(:current) { true }

        it { is_expected.to eql(class: 'success', hex: '#dff0d8') }
      end

      context 'with recent streak' do
        let(:current) { false }
        let(:recent) { true }

        it { is_expected.to eql(class: 'warning', hex: '#fcf8e3') }
      end

      context 'with no recent streak' do
        let(:current) { false }
        let(:recent) { false }

        it { is_expected.to eql(class: 'danger', hex: '#ebcccc') }
      end
    end

    context 'with no streaks' do
      it { is_expected.to eql(class: 'default', hex: nil) }
    end
  end
end
