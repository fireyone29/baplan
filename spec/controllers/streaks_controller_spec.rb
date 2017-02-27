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
    params[:date] = { year: 2017.to_s,
                      month: 2.to_s,
                      date: 41.to_s }  # Feb doesn't have 41 days...
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
      date: date_to_hash(date),
    }.merge(additional_params)
  }
  let(:additional_params) { {} }

  describe "POST #execute" do
    let(:date) { Date.today }
    subject { post :execute, params: params }

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

  describe "POST #unexecute" do
    let(:date) { streak.end_date }
    let(:additional_params) { {id: streak.to_param} }
    subject { post :unexecute, params: params }

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
    end

    it_behaves_like "rejects unauthorized access"
  end
end
