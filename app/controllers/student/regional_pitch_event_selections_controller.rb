module Student
  class RegionalPitchEventSelectionsController < StudentController
    def show
      if params[:event_id]
        do_create(params)
      else
        do_destroy
      end
    end

    def create
      do_create(params)
    end

    def destroy
      do_destroy
    end

    private
    def do_destroy
      old_event = current_team.selected_regional_pitch_event

      current_team.regional_pitch_events.destroy_all

      SendPitchEventRSVPNotifications.perform_later(
        current_team.id,
        leaving_event_id: old_event.id
      )

      redirect_to [:student, :dashboard],
        success: t("controllers.student.regional_pitch_event_selections.destroy.success")
    end

    def do_create(params)
      old_event = current_team.selected_regional_pitch_event

      current_team.regional_pitch_events.destroy_all

      event = RegionalPitchEvent.find(params.fetch(:event_id))
      current_team.regional_pitch_events << event
      current_team.save!

      SendPitchEventRSVPNotifications.perform_later(
        current_team.id,
        leaving_event_id: old_event.id,
        joining_event_id: event.id
      )

      redirect_to [:student, current_team.selected_regional_pitch_event],
        success: t("controllers.student.regional_pitch_event_selections.create.success")
    end
  end
end
