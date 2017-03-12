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
                      date: 41.to_s } # Feb doesn't have 41 days...
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
      date: date_to_hash(date)
    }.merge(additional_params)
  }
  let(:additional_params) { {} }
  let(:previous_url) { '/abc123' }
  let(:session) { { streaks_previous_url: previous_url } }
  let(:referer) { nil }

  before do
    request.env['HTTP_REFERER'] = referer if referer && request && request.env
  end

  describe 'POST #execute' do
    let(:date) { Time.zone.today }
    subject { post :execute, params: params, session: session }

    context 'signed in', :signed_in do
      context 'when referer is execute form' do
        let(:referer) { goal_streaks_execute_path(goal) }

        it 'redirects to the url from session' do
          subject
          expect(response).to redirect_to previous_url
        end
      end

      context 'when referer is not execute form' do
        let(:referer) { 'xyz987' }

        it 'redirects to the url from session' do
          subject
          expect(response).to redirect_to referer
        end
      end

      context 'when referer is not set' do
        it 'redirects to root' do
          subject
          expect(response).to redirect_to ''
        end
      end

      it 'calls update_or_create' do
        expect(Goal).to receive(:find).with(goal.to_param).and_return(goal)
        expect(goal).to receive(:update_or_create!)
        subject
      end

      it_behaves_like 'handles invalid streak params'
    end

    it_behaves_like 'rejects unauthorized access'
  end

  describe 'POST #unexecute' do
    let(:date) { streak.end_date }
    let(:additional_params) { { id: streak.to_param } }
    subject { post :unexecute, params: params, session: session }

    context 'signed in', :signed_in do
      context 'when referer is execute form' do
        let(:referer) { goal_streaks_unexecute_path(goal) }

        it 'redirects to the url from session' do
          subject
          expect(response).to redirect_to previous_url
        end
      end

      context 'when referer is not execute form' do
        let(:referer) { 'xyz987' }

        it 'redirects to the url from session' do
          subject
          expect(response).to redirect_to referer
        end
      end

      context 'when referer is not set' do
        it 'redirects to root' do
          subject
          expect(response).to redirect_to ''
        end
      end

      it 'unexecutes the correct date' do
        subject
        expect(streak.reload.start_date.to_s).not_to eql date
      end

      it_behaves_like 'handles invalid streak params'
    end

    it_behaves_like 'rejects unauthorized access'
  end
end
