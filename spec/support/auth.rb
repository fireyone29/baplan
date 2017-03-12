RSpec.shared_context 'signed in user', shared_context: :metadata do
  before do
    sign_in user
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'signed in user', :signed_in
end

RSpec.shared_examples 'rejects unauthorized access' do
  it 'redirects to login' do
    subject
    expect(response).to redirect_to(new_user_session_path)
  end
end
