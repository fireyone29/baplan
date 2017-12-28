require 'rails_helper'

# These tests use the anonymous controller fuctionality from RSpec:
# https://www.relishapp.com/rspec/rspec-rails/v/3-0/docs/controller-specs/anonymous-controller
RSpec.describe ApplicationController, type: :controller do
  # Create an anonymous controller that does nothing
  controller do
    include DeviseHelpers

    def index
      render json: {}
    end
  end

  subject { get :index }

  describe '#set_time_zone' do
    # Note: you need to use real time zone name values

    before do
      # reset timezone before each test, since it's persisted
      # otherwise
      Time.zone = nil
    end

    context 'without user' do
      context 'with no time zone information' do
        it 'does not do anything' do
          expect(Time).not_to receive(:zone)
          subject
        end
      end
    end

    context 'with signed in user', :signed_in do
      let(:user) { FactoryBot.create(:user) }

      context 'with no time zone information' do
        it 'warns the user with a flash message' do
          subject
          expect(flash[:alert]).to match(/time zone not set/i)
        end
      end

      context 'with time zone configured on the user' do
        let(:time_zone) { 'Eastern Time (US & Canada)' }
        let(:user) { FactoryBot.create(:user, time_zone: time_zone) }

        it 'sets the configured time zone' do
          expect(Time.zone.name).not_to eql time_zone
          subject
          expect(Time.zone.name).to eql time_zone
        end

        context 'with time zone cookie also set' do
          let(:cookie_time_zone) { 'Alaska' }

          before do
            cookies[:time_zone] = cookie_time_zone
          end

          it 'ignores the cookie' do
            expect(Time.zone.name).not_to eql time_zone
            subject
            expect(Time.zone.name).to eql time_zone
            expect(Time.zone.name).not_to eql cookie_time_zone
          end
        end
      end

      context 'with time zone cookie set' do
        let(:cookie_time_zone) { 'Alaska' }

        before do
          cookies[:time_zone] = cookie_time_zone
        end

        it 'sets the time zone from the cookie' do
          expect(Time.zone.name).not_to eql cookie_time_zone
          subject
          expect(Time.zone.name).to eql cookie_time_zone
        end
      end
    end
  end

  describe '#configure_devise_parameters' do
    before do
      allow(controller).to receive(:devise_controller?).and_return(true)
    end

    it 'does not explode' do
      subject
    end
  end
end
