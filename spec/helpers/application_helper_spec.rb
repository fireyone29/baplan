require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_messages' do
    subject { helper.flash_messages }

    it { is_expected.to be_a Hash }

    context 'with no messages' do
      it 'returns an empty hash' do
        expect(subject).to eql({})
      end
    end

    context 'with some flash messages' do
      let(:value) { 'my_flash_message' }

      before do
        flash[:alert] = value
        flash[:success] = value
        flash[:notice] = ''
        flash[:error] = value
      end

      it 'returns the messages that are present' do
        expect(subject[:alert]).to eql value
        expect(subject[:error]).to eql value
        expect(subject[:success]).to eql value
      end

      it 'does not return blank values' do
        expect(subject).not_to include(:notice)
      end
    end
  end
end
