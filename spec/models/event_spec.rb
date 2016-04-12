require 'rails_helper'

describe Event, type: :model do
  describe '.is_virtual' do
    subject(:event) { build(:event) }

    it { is_expected.to respond_to(:is_virtual) }

    context 'when not set up' do
      subject { event.is_virtual }

      it { is_expected.to be_nil }
    end
  end

  describe '.open_for_signup_by_region' do
    let(:fake_relation){ double(where: nil) }
    let(:region_id){ Faker::Number.number(5) }

    before do
      allow(Event).to receive(:display_order).and_return(fake_relation)
    end

    it 'respond to open_for_signup_by_region' do
      expect(Event).to respond_to(:open_for_signup_by_region)
    end

    it 'calls display_order_scope' do
      expect(Event).to receive(:display_order)
      Event.open_for_signup_by_region(region_id)
    end

    it 'filter by region' do
      expect(fake_relation).to receive(:where).with(region_id: region_id)
      Event.open_for_signup_by_region(region_id)

    end

  end

  describe '.virtual' do
    subject { described_class }

    it { is_expected.to respond_to(:virtual) }

    context 'when there is a virtual event' do
      subject { Event.virtual }

      context 'and there are events for different seasons' do
        let(:current_when_to_occur) { DateTime.new(2016, 1, 1) }
        let(:previous_when_to_occur) { DateTime.new(2015, 1, 1) }

        let(:expected_event) { create(:event, :virtual_event, whentooccur: current_when_to_occur) }

        before do
          allow(Setting).to receive(:year).and_return(2016)
          create(:event, :virtual_event, whentooccur: previous_when_to_occur)
          create(:event, :non_virtual_event, whentooccur: current_when_to_occur)
          create(:event, :non_virtual_event, whentooccur: previous_when_to_occur)
        end

        it 'returns current season event only' do
          is_expected.to contain_exactly(expected_event)
        end
      end
    end

    describe '.virtual_for_current_season' do
      subject { Event.virtual_for_current_season }
      let(:event) { double }
      let(:virtual_event_results) { [event, event] }

      before do
        allow(Event).to receive(:virtual).and_return(virtual_event_results)
      end

      it 'calls virtual event scope' do
        subject
        expect(Event).to have_received(:virtual)
      end

      it 'returns the first virtual event for the current season' do
        is_expected.to eq(event)
      end
    end
  end
  describe '.display_order' do
    let(:event) { double }
    let(:result) { [event, event] }

    before do
      allow(Event).to receive(:order).with(is_virtual: :desc, name: :asc)
    end
    it 'calls display_order with the right parameters' do
      Event.display_order
      expect(Event).to have_received(:order).with(is_virtual: :desc, name: :asc)
    end
  end
end
