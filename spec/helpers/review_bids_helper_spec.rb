# spec/helpers/review_bids_helper_spec.rb

require 'rails_helper'
require 'review_bids_helper'

RSpec.describe ReviewBidsHelper, type: :helper do
  describe '#get_intelligent_topic_row_review_bids' do
    let(:topic) { double('Topic', id: 1) }
    let(:selected_topic) { double('SelectedTopic', topic_id: 1, is_waitlisted: false) }
    let(:num_participants) { 5 }
    let(:review_bid) { double('ReviewBid') }

    context 'when selected topics are present' do
      it 'returns HTML code for topic row with appropriate background color' do
        selected_topic = instance_double('SelectedTopic', topic_id: 1, is_waitlisted: false)
        allow(selected_topic).to receive_message_chain(:topic_id, :==).and_return(true)
        allow(selected_topic).to receive(:is_waitlisted).and_return(false)
        selected_topics = [selected_topic]
    
        expect(helper.get_intelligent_topic_row_review_bids(topic, selected_topics, num_participants)).to include('<tr bgcolor="yellow">')
      end
    end
    
    context 'when selected topic is waitlisted' do
      it 'returns HTML code for topic row with appropriate background color' do
        selected_topic = instance_double('SelectedTopic', topic_id: 1, is_waitlisted: true)
        allow(selected_topic).to receive_message_chain(:topic_id, :==).and_return(true)
        allow(selected_topic).to receive(:is_waitlisted).and_return(true)
        selected_topics = [selected_topic]
    
        expect(helper.get_intelligent_topic_row_review_bids(topic, selected_topics, num_participants)).to include('<tr bgcolor="lightgray">')
      end
    end
    
    

    context 'when selected topics are not present' do
      it 'returns HTML code for topic row with appropriate background color' do
        allow(helper).to receive(:get_topic_bg_color_review_bids).and_return('rgb(255,255,255)')
        selected_topics = []

        expect(helper.get_intelligent_topic_row_review_bids(topic, selected_topics, num_participants)).to include('<tr id="topic_1" style="background-color:rgb(255,255,255)">')
      end
    end

    context 'when selected topics are nil' do
      it 'returns HTML code for topic row with appropriate background color' do
        selected_topics = nil

        expect(helper.get_intelligent_topic_row_review_bids(topic, selected_topics, num_participants)).to include('<tr id="topic_1" style="background-color:rgb(47,352,0)">')
      end
    end
  end

  describe '#get_topic_bg_color_review_bids' do
    let(:topic) { double('Topic', id: 1) }
    let(:review_bid) { double('ReviewBid') }
    let(:num_participants) { 5 }

    it 'returns RGB color code for topic background color' do
      allow(ReviewBid).to receive(:where).with(signuptopic_id: topic.id).and_return([review_bid])

      expect(helper.get_topic_bg_color_review_bids(topic, num_participants)).to match(/^rgb\(\d+,\d+,\d+\)$/)
    end

    context 'when there are no review bids' do
      it 'returns default RGB color code' do
        allow(ReviewBid).to receive(:where).with(signuptopic_id: topic.id).and_return([])

        expect(helper.get_topic_bg_color_review_bids(topic, num_participants)).to eq('rgb(47,352,0)')
      end
    end
  end
end
