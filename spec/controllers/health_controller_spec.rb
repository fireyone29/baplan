require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  subject { get :show }

  it 'succeeds' do
    subject
    expect(response).to be_successful
  end

  it 'contains the version' do
    subject
    expect(response.body).to include Rails.application.class::VERSION
  end
end
