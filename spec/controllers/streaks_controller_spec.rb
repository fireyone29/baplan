require 'rails_helper'

RSpec.shared_examples 'handles invalid streak params' do
  it 'rejects goals not owned by current user' do
    new_streak = FactoryGirl.create(:streak)
    params[:goal_id] = new_streak.goal.to_param
    params[:id] = new_streak.to_param
    subject
    expect(response).to redirect_to(goals_path)
  end

  it 'rejects request with nil date' do
    params[:date] = nil
    expect{subject}.to raise_error(ActionController::BadRequest)
  end

  it 'rejects request with empty date' do
    params[:date] = ''
    expect{subject}.to raise_error(ActionController::BadRequest)
  end

  it 'rejects request with invalid date' do
    params[:date] = { year: 2017.to_s,
                      month: 2.to_s,
                      date: 41.to_s } # Feb doesn't have 41 days...
    expect{subject}.to raise_error(ActionController::BadRequest)
  end

  it 'rejects request with date missing information' do
    params[:date] = { year: 2017.to_s,
                      month: 2.to_s }
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
  let(:referer) { nil }

  before do
    request.env['HTTP_REFERER'] = referer if referer && request && request.env
  end

  describe 'POST #execute' do
    let(:session) { { streaks_previous_url: previous_url } }
    let(:date) { Time.zone.today - 2.days }
    subject { post :execute, params: params, session: session }

    context 'signed in', :signed_in do
      context 'when referer is execute form' do
        let(:referer) { goal_execute_path(goal) }

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
        expect(goal).to receive(:update_or_create!).with(date)
        subject
      end

      context 'with no date provided' do
        it 'calls update_or_create with today' do
          params.delete(:date)
          expect(Goal).to receive(:find).with(goal.to_param).and_return(goal)
          expect(goal).to receive(:update_or_create!).with(Time.zone.today)
          subject
        end
      end

      it_behaves_like 'handles invalid streak params'
    end

    it_behaves_like 'rejects unauthorized access'
  end

  describe 'GET #execute_form' do
    let(:date) { Time.zone.today - 2.days }
    let(:referer) { '/abc' }
    subject { get :execute_form, params: params }

    context 'signed in', :signed_in do
      it 'saves the referer to the session' do
        subject
        expect(session[:streaks_previous_url]).to eql referer
      end
    end

    it_behaves_like 'rejects unauthorized access'
  end

  describe 'POST #unexecute' do
    let(:session) { { streaks_previous_url: previous_url } }
    let(:date) { streak.end_date }
    let(:additional_params) { { id: streak.to_param } }
    subject { post :unexecute, params: params, session: session }

    context 'signed in', :signed_in do
      context 'when referer is execute form' do
        let(:referer) { goal_unexecute_path(goal) }

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

      context 'with no date provided' do
        let!(:streak) {
          FactoryGirl.create(:weekly_streak,
                             start_date: Time.zone.today)
        }

        it 'unexecutes today' do
          params.delete(:date)
          subject
          expect(streak.reload.start_date.to_s).not_to eql Time.zone.today
        end
      end

      it_behaves_like 'handles invalid streak params'
    end

    it_behaves_like 'rejects unauthorized access'
  end

  describe 'GET #unexecute_form' do
    let(:date) { Time.zone.today - 2.days }
    let(:referer) { '/abc' }
    subject { get :unexecute_form, params: params }

    context 'signed in', :signed_in do
      it 'saves the referer to the session' do
        subject
        expect(session[:streaks_previous_url]).to eql referer
      end
    end

    it_behaves_like 'rejects unauthorized access'
  end

  describe 'GET #find' do
    let(:params) {
      {
        goal_id: goal.to_param
      }.merge(additional_params)
    }
    let(:json_body) { JSON.parse(response.body) }
    subject { get :find, format: :json, params: params, session: session }

    context 'signed in', :signed_in do
      context 'with no params' do
        it 'returns all streaks' do
          subject
          expect(response).to be_successful
          expect(assigns(:streaks)).to match_array [streak]
        end
      end

      context 'with no streaks' do
        let!(:goal) { FactoryGirl.create(:goal) }

        it 'is empty' do
          subject
          expect(response).to be_successful
          expect(assigns(:streaks)).to be_empty
        end

        context 'with streaks on other goals' do
          before do
            FactoryGirl.create(:daily_streak)
          end

          it 'is empty' do
            subject
            expect(response).to be_successful
            expect(assigns(:streaks)).to be_empty
          end
        end
      end

      context 'with a variety of streaks' do
        let(:goal) { FactoryGirl.create(:goal) }
        let!(:streak1) {
          FactoryGirl.create(:streak,
                             goal_id: goal.id,
                             start_date: '2017-03-04',
                             end_date: '2017-04-04')
        }
        let!(:streak2) {
          FactoryGirl.create(:streak,
                             goal_id: goal.id,
                             start_date: '2016-08-15',
                             end_date: '2017-01-01')
        }
        let!(:streak3) {
          FactoryGirl.create(:streak,
                             goal_id: goal.id,
                             start_date: '2017-03-01',
                             end_date: '2017-03-02')
        }

        context 'with a year filter on start date' do
          let(:additional_params) { { start_date: '2017' } }

          it 'returns matching streaks' do
            subject
            expect(response).to be_successful
            expect(assigns(:streaks)).to match_array [streak1, streak3]
          end
        end

        context 'with a month filter on end date' do
          let(:additional_params) { { end_date: '2017-03' } }

          it 'returns matching streaks' do
            subject
            expect(response).to be_successful
            expect(assigns(:streaks)).to match_array [streak3]
          end
        end

        context 'with a day filter' do
          let(:additional_params) { { start_date: '2017-03-04' } }

          it 'returns matching streaks' do
            subject
            expect(response).to be_successful
            expect(assigns(:streaks)).to match_array [streak1]
          end
        end

        context 'with no filter' do
          it 'returns all streaks' do
            subject
            expect(response).to be_successful
            expect(assigns(:streaks)).to match_array [streak1, streak2, streak3]
          end
        end
      end
    end

    it_behaves_like 'rejects unauthorized json access'
  end
end
