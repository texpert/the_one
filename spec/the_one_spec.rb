# frozen_string_literal: true

require 'faker'
require 'spec_helper'
require_relative '../lib/the_one'
Dir['./lib/*/**'].each { |file| require file }

RSpec.describe TheOne do
  context '#run method' do
    before do
      allow(HTTPX).to receive(:headers).with('accept' => 'application/json')
      allow(TheOne).to receive(:new).and_call_original
      allow_any_instance_of(TheOne).to receive(:run)
    end

    it 'creates a instance of TheOne class with default parameters, when no params are passed in the call' do
      allow(TheOne).to receive(:new).with(client: HTTPX.headers('accept' => 'application/json'), url: TheOne::BASE_URI)
                                    .and_call_original

      expect(TheOne).to receive(:new).with(client: HTTPX.headers('accept' => 'application/json'), url: TheOne::BASE_URI)

      described_class.run
    end

    it 'creates a instance of TheOne class with passed parameters, when the params are passed in the call' do
      client = double('Client')
      url = Faker::Internet.url
      allow(TheOne).to receive(:new).with(client: client, url: url).and_call_original

      expect(TheOne).to receive(:new).with(client: client, url: url)

      described_class.run(http_client: client, url: url)
    end

    it 'calls the run method on the created instance of TheOne class' do
      expect_any_instance_of(TheOne).to receive(:run)
      described_class.run
    end

    context 'calling private methods from the run method' do
      let(:resource) do
        { start_node: 'alpha',
          end_node:   'beta',
          start_time: '2030-12-31T13:00:01',
          end_time:   '2030-12-31T13:00:02' }
      end

      before do
        allow_any_instance_of(TheOne).to receive(:fetch_resource)
        allow_any_instance_of(TheOne).to receive(:run).and_call_original
        allow_any_instance_of(SentinelsDataCoerser).to receive(:run).and_return([])
        allow_any_instance_of(SniffersDataCoerser).to receive(:run).and_return([])
        allow_any_instance_of(LoopholesDataCoerser).to receive(:run).and_return([])
        allow_any_instance_of(TheOne).to receive(:override_csv_converters)
      end

      it 'overrides csv_converters hash, and restores it to original after running' do
        original_csv_converter = CSV::Converters
        expect_any_instance_of(TheOne).to receive(:override_csv_converters)

        described_class.run

        expect(CSV::Converters).to eql(original_csv_converter)
      end

      it 'calls the fetch_resource method on the created instance of TheOne class for all specified sources' do
        expect_any_instance_of(TheOne).to receive(:fetch_resource).exactly(TheOne::SOURCES.size).times

        described_class.run
      end

      it 'calls the DataCoerser for each fetched resource' do
        TheOne::SOURCES.each do |source|
          expect(Object.const_get("#{source.capitalize}DataCoerser")).to receive(:run).and_return([])
        end

        described_class.run
      end

      it 'sends the data from each source via http_client in a POST request' do
        allow_any_instance_of(SentinelsDataCoerser).to receive(:run).and_return([resource])
        allow_any_instance_of(SniffersDataCoerser).to receive(:run).and_return([resource])
        allow_any_instance_of(LoopholesDataCoerser).to receive(:run).and_return([resource])
        allow(HTTPX).to receive(:headers).with('accept' => 'application/json').and_call_original

        TheOne::SOURCES.each do |source|
          allow_any_instance_of(HTTPX::Session).to receive(:request)
            .with(:post, [TheOne::BASE_URI], json: resource.merge!(passphrase: TheOne::PASSPHRASE, source: source))

          expect_any_instance_of(HTTPX::Session).to receive(:request)
            .with(:post, [TheOne::BASE_URI], json: resource.merge!(passphrase: TheOne::PASSPHRASE, source: source))
          described_class.run
        end
      end
    end
  end
end
