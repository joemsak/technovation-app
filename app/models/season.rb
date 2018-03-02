class Season < ActiveRecord::Base
  has_many :registrations, class_name: "SeasonRegistration"

  validates :year,
    presence: true,
    numericality: true,
    uniqueness: { case_sensitive: false }

  def self.current
    find_or_create_by(year: 2017)
  end

  def self.next
    season = current

    unless SeasonToggles.registration_closed? and
             Date.today >= switch_date
      season.year = current.year + 1
    end

    season
  end

  def self.for(record)
    2017
  end

  def self.switch_date(year = Time.current.year)
    Date.new(year, switch_month, switch_day)
  end

  def self.switch_month
    10
  end

  def self.switch_day
    1
  end
end
