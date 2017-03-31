require 'rails_helper'

RSpec.describe StreaksController, type: :routing do
  describe 'routing' do
    let(:goal_id) { '1' }
    let(:root) { "/goals/#{goal_id}" }

    it 'routes to #execute_form' do
      expect(get: "#{root}/execute").to route_to('streaks#execute_form',
                                                 goal_id: goal_id)
    end

    it 'routes to #execute' do
      expect(post: "#{root}/execute").to route_to('streaks#execute',
                                                  goal_id: goal_id)
    end

    it 'routes to #unexecute_form' do
      expect(get: "#{root}/unexecute").to route_to('streaks#unexecute_form',
                                                   goal_id: goal_id)
    end

    it 'routes to #unexecute' do
      expect(post: "#{root}/unexecute").to route_to('streaks#unexecute',
                                                    goal_id: goal_id)
    end

    it 'routes to #find' do
      expect(get: "#{root}/streaks").to route_to('streaks#find',
                                                 goal_id: goal_id)
    end
  end
end
