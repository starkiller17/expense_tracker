RSpec.configure do |c|
  # Runs after all specs have been loaded but before the first one actually runs
  c.before(:suite) do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    DB[:expenses].truncate
  end

  # For each example marked as requiring the database :db, the following happen
  # RSpec calls our around hook, passing it the example we're running
  # Inside the hook, we tell Sequel to start a new DB transaction
  # Sequel calls the inner block, in which we tell RSpec to run the example
  # The body of the example finishes running
  # Sequel rolls back the transaction, wiping out any changes we made to the DB
  # The around hook finishes, and RSpec moces on to the next example.
  c.around(:example, :db) do |example|
    DB.transaction(rollback: :always) {example.run}
  end
end