require 'rails_helper'

RSpec.shared_examples 'handles invalid streak params' do
  it 'rejects goals not owned by current user' do
    new_streak = FactoryGirl.create(:streak)
    params[:goal_id] = new_streak.goal.to_param
    params[:id] = new_streak.to_param
    subject
    expect(response).to redirect_to(goals_path)
  end

  it 'rejects request without a date' do
    params.delete(:date)
    expect{subject}.to raise_error(ActionController::ParameterMissing)
  end

  it 'rejects request with no date' do
    params[:date] = nil
    expect{subject}.to raise_error(ActionController::ParameterMissing)
  end

  it 'rejects request with empty date' do
    params[:date] = ''
    expect{subject}.to raise_error(ActionController::ParameterMissing)
  end

  it 'rejects request with invalid date' do
    params[:date] = '2017-02-41' # Feb doesn't have 41 days...
    expect{subject}.to raise_error(ActionController::BadRequest)
  end
end

RSpec.describe StreaksController, type: :controller do
  let!(:streak) { FactoryGirl.create(:weekly_streak) }
  let(:goal) { streak.goal }
  let(:user) { goal.user }
  let(:params) {
    {
      goal_id: goal.to_param,
      date: date.to_s,
    }.merge(additional_params)
  }
  let(:additional_params) { {} }

  describe "GET #create" do
    let(:date) { Date.today }
    subject { get :create, params: params }

    context 'signed in', :signed_in do
      it "redirects to the relevant goal" do
        subject
        expect(response).to redirect_to(goal_path(goal))
      end

      it 'calls update_or_create' do
        expect(Goal).to receive(:find).with(goal.to_param).and_return(goal)
        expect(goal).to receive(:update_or_create!)
        subject
      end

      it_behaves_like "handles invalid streak params"
    end

    it_behaves_like "rejects unauthorized access"
  end

  describe "GET #edit" do
    let(:date) { streak.end_date + 1.day }
    let(:additional_params) { {id: streak.to_param} }
    subject { get :edit, params: params }

    context 'signed in', :signed_in do
      it 'redirects to the relevant goal' do
        subject
        expect(response).to redirect_to(goal_path(goal))
      end

      it 'calls execute on the streak' do
        expect(Streak).to receive(:find).with(streak.to_param).and_return(streak)
        expect(streak).to receive(:execute).with(date)
        subject
      end

      context 'when executing streak fails' do
        before do
          expect(Streak).to receive(:find).with(streak.to_param).and_return(streak)
          expect(streak).to receive(:execute).and_return(false)
          expect(Goal).to receive(:find).with(goal.to_param).and_return(goal)
        end

        it 'calls update_or_create on the goal' do
          expect(goal).to receive(:update_or_create!).with(date).and_call_original
          subject
        end
      end

      it_behaves_like "handles invalid streak params"

      it 'rejects goal and streak ids which do not match' do
        params[:id] = FactoryGirl.create(:streak).to_param
        expect{subject}.to raise_error(ActionController::BadRequest)
      end
    end

    it_behaves_like "rejects unauthorized access"
  end

  describe "DELETE #destroy" do
    let(:date) { streak.end_date }
    let(:additional_params) { {id: streak.to_param} }
    subject { delete :destroy, params: params }

    context 'signed in', :signed_in do
      it "redirects to the relevant goal" do
        subject
        expect(response).to redirect_to(goal_path(goal))
      end

      it "unexecutes the correct date" do
        subject
        expect(streak.reload.start_date.to_s).not_to eql date
      end

      it_behaves_like "handles invalid streak params"

      it 'rejects goal and streak ids which do not match' do
        params[:id] = FactoryGirl.create(:streak).to_param
        expect{subject}.to raise_error(ActionController::BadRequest)
      end
    end

    it_behaves_like "rejects unauthorized access"
  end
end
