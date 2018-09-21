class SignupsController < ApplicationController
  before_action :require_unauthenticated

  helper_method :admin_permission?, :signup_available?, :signup_wizard_mode?

  def new
    if signup_wizard_mode?
      init_signup_wizard_mode
    else
      init_legacy_mode
    end
  end

  private
  def signup_wizard_mode?
    !admin_permission_signup_attempt &&
      get_cookie(CookieNames::SIGNUP_WIZARD_MODE)
  end

  def init_signup_wizard_mode
    if token = get_cookie(CookieNames::SIGNUP_TOKEN)
      @signup_attempt = SignupAttempt.wizard.find_by(wizard_token: token)

      if @signup_attempt && !@signup_attempt.country_code

        if result = Geocoder.search(
            get_cookie(CookieNames::IP_GEOLOCATION)['coordinates'],
            lookup: :google
          ).first

          geocoded = Geocoded.new(result)
          @signup_attempt.update({
            city: geocoded.city,
            state_code: geocoded.state_code,
            country_code: geocoded.country_code,
            latitude: geocoded.latitude,
            longitude: geocoded.longitude,
          })

        end
      end
    end
  end

  def init_legacy_mode
    if attempt = admin_permission_signup_attempt
      set_cookie(CookieNames::SIGNUP_TOKEN, attempt.signup_token)
      set_cookie(CookieNames::ADMIN_PERMISSION_TOKEN, attempt.admin_permission_token)
    end

    if attempt &&
        attempt.account.present? &&
          attempt.account.regional_ambassador_profile.present?
      redirect_to regional_ambassador_signup_path
    elsif not !!get_cookie(CookieNames::SIGNUP_TOKEN)
      redirect_to root_path
    end
  end

  def signup_available?(type)
    SeasonToggles.public_send("#{type}_signup?") or admin_permission?
  end

  def admin_permission?
    !!get_cookie(CookieNames::ADMIN_PERMISSION_TOKEN)
    # TODO: check token validity
  end

  def admin_permission_signup_attempt
    return @admin_permission_signup_attempt if defined?(@admin_permission_signup_attempt)

    if !params[:admin_permission_token].blank?
      @admin_permission_signup_attempt = SignupAttempt.find_by(
        admin_permission_token: params[:admin_permission_token]
      )
    else
      false
    end
  end
end
