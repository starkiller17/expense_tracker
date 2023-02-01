require_relative '../../../app/api'
require 'rack/test'
require_relative '../../support/helpers/utils'

module ExpenseTracker
  # RecordResult = Struct.new(:success?, :expense_id, :error_message)

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }
        
        # Calling the allow method from rspec-mocks, to configure the test double's behavior
        # When the caller (the API class) invokes record, the double will return a new RecordResult
        # instance indicating a successfull posting
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          puts "*" * 100
          puts expense
          puts "*" * 100
          post '/expenses', JSON.generate(expense)

          parsed = json_response
          expect(parsed).to include('expense_id' => 417)
        end
        
        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(json_response).to include('error' => 'Expense incomplete')
        end

        it 'reponds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date'  do
      context 'when expenses exist on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2017-06-12')
            .and_return(['expense_1', 'expense_2'])            
        end

        it 'returns the expense records as JSON' do
          get '/expenses/2017-06-12'

          parsed = JSON.parse(last_response.body)
          expect(json_response).to eq(['expense_1', 'expense_2'])
        end

        it 'responds with a 200 (OK)' do
          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2023-01-30')
            .and_return([])
        end

        it 'returns an empty array as JSON' do
          get 'expenses/2023-01-30'
          parsed = JSON.parse(last_response.body)
          expect(json_response).to eq([])
        end

        it 'responds with a 200 (OK)' do
          get 'expenses/2023-01-30'
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end