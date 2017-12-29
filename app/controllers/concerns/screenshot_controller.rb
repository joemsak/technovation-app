module ScreenshotController
  extend ActiveSupport::Concern

  included do
    include ActionView::Helpers::AssetTagHelper
    include ActionView::RecordIdentifier
  end

  def index
    screenshots = current_team.submission.screenshots.map do |s|
      {
        id: s.id,
        image_url: s.image_url,
        image_alt: image_alt(s.image_url),
        sort_position: s.sort_position,
        delete_url: send("#{current_scope}_screenshot_url", s),
      }
    end

    render json: screenshots
  end

  def create
    # TODO: ARRAY() ADDED TO GET THE SCREENSHOT BECAUSE
    # THE ORIGINAL CREATE LINE RETURNS AN OBJECT
    # THAT THINKS IT IS AN ARRAY
    # NO IDEA WHY - Joe Sak

    @screenshot = Array(current_team.submission.screenshots.create!(
      screenshot_params
    )).first

    render json: {
      removeUrl: send(
        "#{current_scope}_screenshot_path",
        @screenshot,
        team_submission: {
          id: @screenshot.team_submission_id,
        }
      )
    }
  end

  def destroy
    screenshot = Screenshot.find(params[:id])

    if current_team.submission.screenshots.include?(screenshot)
      screenshot.destroy
      render json: {}
    else
      render json: {}, status: 403
    end
  end

  private
  def screenshot_params
    params.require(:team_submission).permit(
      screenshots_attributes: [
        :image,
      ],
    ).fetch(:screenshots_attributes)
  end
end
