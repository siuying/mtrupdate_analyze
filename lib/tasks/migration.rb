namespace :db do
  desc "Migrate database"
  task :migrate_1 do
    database = Sequel.connect Settings.database.uri
    database.alter_table :tweets do
      add_column :reply, TrueClass, :default => false
      add_column :lang, String, :default => nil
    end
  end
end