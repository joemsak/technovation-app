module Student
  class TeamSubmissionsController < StudentController
    include TeamSubmissionController

    before_action :require_onboarded,
                  :require_current_team

    def edit
      unless SeasonToggles.team_submissions_editable?
        redirect_to student_dashboard_path and return
      end

      @team_submission = current_team.submission
      @team = current_team

      if params[:attributes]
        JSON.parse(params[:attributes]).each do |k, v|
          @team_submission.public_send("#{k}=", v)
        end

        @team_submission.valid?
      end

      @team_submission.screenshots.build

      unless @team_submission.business_plan.present?
        @team_submission.build_business_plan
      end

      unless @team_submission.pitch_presentation.present?
        @team_submission.build_pitch_presentation
      end

      if @team_submission.code_checklist.present?
        @code_checklist = @team_submission.code_checklist
      else
        @code_checklist = @team_submission.build_code_checklist
      end

      if @team_submission.present?
        begin
          render "team_submissions/pieces/#{piece_name}"
        rescue ActionView::MissingTemplate,
               ActionController::ParameterMissing
          redirect_to student_team_submission_path(@team_submission)
        end
      else
        redirect_to new_student_team_submission_path
      end
    end

    def create
      @team_submission = if current_team.submission.present?
                           current_team.submission
                         else
                           current_team.team_submissions.build(
                             team_submission_params
                           )
                         end

      if @team_submission.save
        current_account.create_activity(
          trackable: current_account,
          key: "submission.create",
          recipient: @team_submission,
        )
        redirect_to [:student, @team_submission],
          success: t("controllers.team_submissions.create.success")
      else
        render "team_submissions/new"
      end
    end

    private
    def team_submission_params
      if SeasonToggles.team_submissions_editable?
        params.require(:team_submission).permit(
          :integrity_affirmed,
          :source_code,
          :app_description,
          :app_name,
          :demo_video_link,
          :pitch_video_link,
          :development_platform_other,
          :development_platform,
          :app_inventor_app_name,
          :app_inventor_gmail,
          screenshots: [],
          business_plan_attributes: [
            :id,
            :uploaded_file,
          ],
          pitch_presentation_attributes: [
            :id,
            :uploaded_file,
          ],
        )
      else
        params.require(:team_submission).permit(
          pitch_presentation_attributes: [
            :id,
            :remote_file_url,
          ],
        )
      end
    end
  end
end
