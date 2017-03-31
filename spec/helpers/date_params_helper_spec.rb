require 'rails_helper'

RSpec.describe DateParamsHelper, type: :helper do
  describe '#date_param_to_range' do
    subject { helper.date_param_to_range(date_str) }

    context 'with invalid type' do
      let(:date_str) { nil }

      it 'raises ArgumentError' do
        expect{subject}.to raise_error ArgumentError
      end
    end

    context 'with invalid format' do
      context 'with too many segments' do
        let(:date_str) { '04-04-04-04' }

        it 'raises ArgumentError' do
          expect{subject}.to raise_error ArgumentError
        end
      end

      context 'with invalid date' do
        let(:date_str) { '2017-02-43' }

        it 'raises ArgumentError' do
          expect{subject}.to raise_error ArgumentError
        end
      end

      context 'with empty date' do
        let(:date_str) { '' }

        it 'raises ArgumentError' do
          expect{subject}.to raise_error ArgumentError
        end
      end
    end

    context 'with full date' do
      let(:date) { Time.zone.today }
      let(:date_str) { date.to_param }

      it 'returns a single date' do
        expect(subject).to eql date
      end
    end

    context 'with year and month' do
      let(:date_str) { '2017-03' }
      let(:date) { Date.new(2017, 3, 1) }

      it 'returns a range comprising that month' do
        expect(subject).to eql(date...date.next_month)
      end
    end

    context 'with year' do
      let(:date_str) { '2017' }
      let(:date) { Date.new(2017, 1, 1) }

      it 'returns a range comprising that month' do
        expect(subject).to eql(date...date.next_year)
      end
    end
  end
end
