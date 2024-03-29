require_relative '../../app/api'
require 'rack/test'
require 'json'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API', :db do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    it 'records submitted expenses' do
      pending 'Need to persist expenses'
      coffee = post_expense(
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2017-06-10'
      )

      zoo = post_expense(
        'payee' => 'Zoo',
        'amount' => 15.25,
        'date' => '2017-06-10'
      )

      groceries = post_expense(
        'payee' => 'Whole Foods',
        'amount' => 95.20,
        'date' => '2017-06-11'
      )

      get '/expenses/2017-06-10'
      expect(last_response.status).to eq(200)
      expenses = JSON.parse(last_response.body)
      # Expecting an array that contains coffee and zoo expenses without regard to the order
      expect(expenses).to contain_exactly(coffee, zoo)
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      # A hash containing a key of 'expense_id' and an integer value
      expect(parsed).to include('expense_id' => a_kind_of(Integer))
      expense.merge('id' => parsed['expense_id'])
    end
  end
end