class RegisterToSeasonJob < ActiveJob::Base
  queue_as :default

  def perform(record)
    SeasonRegistration.register(record)
  end
end
