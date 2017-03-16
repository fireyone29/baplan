require 'rails_helper'

RSpec.describe HomeController, type: :routing do
  describe 'routing' do
    it 'routes to #index', pending: 'Need to stub devise somehow' do
      expect(get: '/').to route_to('home#index')
    end

    it 'routes to #about' do
      expect(get: '/about').to route_to('home#about')
    end

    it 'routes to #faq' do
      expect(get: '/faq').to route_to('home#faq')
    end
  end
end
