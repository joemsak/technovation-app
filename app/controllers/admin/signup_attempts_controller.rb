module Admin
  class SignupAttemptsController < AdminController
    def index
      params[:status] = "pending" if params[:status].blank?
      params[:per_page] = WillPaginate.per_page if params[:per_page].blank?
      params[:page] = 1 if params[:page].blank?

      @signup_attempts = SignupAttempt.send(params[:status])
        .where("email LIKE ?", "%#{params[:text]}%")
        .page(params[:page].to_i)
        .per_page(params[:per_page].to_i)
    end
  end
end
