namespace :legacy_migration do
  desc "Import users from the legacy database"
  task import_users: :environment do
    require './lib/legacy/helpers/profile_attributes'
    require './lib/legacy/models/user'

    Legacy::User.find_each do |user|
      account = "#{user.role}_account".camelize.constantize.new(
        email: user.email,
        password_digest: user.encrypted_password,
        first_name: user.first_name,
        last_name: user.last_name,
        date_of_birth: user.birthday,
        city: user.home_city,
        state_province: user.home_state,
        country: user.home_country,
        "#{user.role}_profile_attributes" => ProfileAttributes.(user),
      )
      GenerateToken.(account, :auth_token)
      account.save(validate: false)
      puts "Migrated account for: #{account.email}"
    end

    puts "Migrated #{Account.count} accounts"
  end
end
