module RegionalAmbassador
  class EventAssignmentsController < RegionalAmbassadorController
    def create
      event = RegionalPitchEvent.find(assignment_params.fetch(:event_id))

      invite_params = assignment_params.fetch(:invites)

      invite_params.each do |_, par|
        # params come in strange
        # FIXME in EventJudgeList.vue#saveAssignments form appending...
        # FIXME in EventTeamList.vue#saveAssignments form appending...
        opts = par.first

        unless invite = opts[:scope].constantize.find_by(id: opts[:id])
          invite = opts[:scope].constantize.create!({
            email: opts[:email],
            name: opts[:name],
            profile_type: :judge,
          });
        end

        if opts[:scope] == "MentorProfile"
          invite = invite.create_judge_profile!({
            company_name: invite.school_company_name,
            job_title: invite.job_title,
          })
        end

        unless invite.events.include?(event)
          invite.events << event
        end

        # FIXME "true" == ...
        # make it a real boolean
        if "true" == opts[:send_email]
          if opts[:scope] == "Team"
            invite.memberships.each do |membership|
              EventMailer.invite(
                membership.member_type,
                membership.member_id,
                event.id,
              ).deliver_later
            end
          else
            EventMailer.invite(
              invite.class.name,
              invite.id,
              event.id,
            ).deliver_later
          end
        end
      end

      render json: {
        flash: {
          success: "You saved your selected judges for #{event.name}"
        },
      }
    end

    def destroy
      event = RegionalPitchEvent
        .includes(:judges, :user_invitations)
        .find(assignment_params.fetch(:event_id))

      attendee = event.attendees.detect do |a|
        a.id == assignment_params.fetch(:attendee_id).to_i &&
          a.class.model_name == assignment_params.fetch(:attendee_scope)
      end

      if attendee
        attendee.events.destroy(event)

        if assignment_params.fetch(:attendee_scope) == "Team"
          attendee.memberships.each do |membership|
            EventMailer.notify_removed(
              membership.member_type,
              membership.member_id,
              event.id,
            ).deliver_later
          end
        else
          EventMailer.notify_removed(
            attendee.class.name,
            attendee.id,
            event.id,
          ).deliver_later
        end

        render json: {
          flash: {
            success: "You removed #{attendee.name} from #{event.name}"
          },
        }
      else
        render json: {
          flash: {
            success: "You removed a judge from #{event.name}"
          },
        }
      end
    end

    private
    def assignment_params
      params.require(:event_assignment)
        .permit(
          :event_id,
          :attendee_id,
          :attendee_scope,
          invites: {},
        )
    end
  end
end