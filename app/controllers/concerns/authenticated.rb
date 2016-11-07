module Authenticated
  extend ActiveSupport::Concern

  included do
    before_filter :authenticate!

    before_action -> {
      redirect_to interruptions_path(issue: :invalid_profile) and return
    }, unless: -> {
      current_account.admin? or
      (%w{interruptions profiles}.include?(controller_name) or
        (current_account.valid? and
          current_account.profile_valid?))
    }
  end

  private
  def authenticate!
    unless current_account.authenticated?
      save_redirected_path
      go_to_signin(model_name)
    end
  end
end
