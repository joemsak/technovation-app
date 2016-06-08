require "reform/form/validation/unique_validator"

class Team < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Model
    model Team, :create

    contract do
      property :name
      property :description
      property :division_id
      property :region_id

      validates :name, unique: true, presence: true
      validates :description, presence: true
      validates :division_id, presence: true
      validates :region_id, presence: true
    end

    def process(params)
      validate(params.fetch(:team)) do |f|
        f.save

        register_in_current_year!
      end
    end

    private
    def register_in_current_year!
      SeasonRegistration::Create.(season_registration: { registerable: model })
    end
  end
end
