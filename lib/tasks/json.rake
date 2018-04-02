namespace :json do
  desc "Export all data to JSON files"
  task :export => :environment do
    Rails.application.eager_load!

    file = File.open(File.join(Rails.root, "db", "export", "accounts.json"), 'w')
    file.write Account.find_by(email: "joe+s@joesak.com").to_json
    file.close
  end
end