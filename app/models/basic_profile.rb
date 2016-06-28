class BasicProfile < ActiveRecord::Base
  include Authenticatable

  validates :date_of_birth, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :city, presence: true
  validates :region, presence: true
  validates :country, presence: true

  def address_details
    [city, region, country].join(', ')
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def sign_consent_form!
    update_attributes(consent_signed_at: Time.current)
  end
end
