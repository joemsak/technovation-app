require 'uri'

class ExportEventAttendeesJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  queue_as :default

  before_enqueue do |job|
    ambassador = RegionalAmbassadorProfile.find(job.arguments.first)

    db_job = Job.create!(
      owner: ambassador,
      job_id: job.job_id,
      status: "queued"
    )

    broadcast(db_job, ambassador)
  end

  after_perform do |job|
    ambassador = RegionalAmbassadorProfile.find(job.arguments.first)

    db_job = Job.find_by(job_id: job.job_id)
    db_job.update_column(:status, "complete")

    broadcast(db_job, ambassador)
  end

  def perform(ambassador_id, event_id, context_klass_name, list_type)
    ambassador = RegionalAmbassadorProfile.find(ambassador_id)
    event = RegionalPitchEvent.find(event_id)

    filepath = "./tmp/#{event.name.parameterize}-#{list_type}.csv"

    context_klass = context_klass_name.constantize

    case list_type
    when "judge_list"
      prepare_judge_csv(event, filepath)
    when "teams"
      prepare_team_csv(event, filepath)
    else; raise "List type #{list_type} not supported in EventAttendeesExport"
    end

    ambassador.exports.create!(
      file: File.open(filepath),
      job_id: job_id
    )
  end

  private
  def prepare_judge_csv(event, filepath)
    CSV.open(filepath, "wb+") do |csv|
      csv << %w{name email status explanation}
      event.judge_list.each do |item|
        csv << [
          item.name,
          item.email,
          item.status,
          item.status_explained,
        ]
      end
    end
  end

  def prepare_team_csv(event, filepath)
    CSV.open(filepath, "wb+") do |csv|
      csv << %w{team submission division percent\ complete, presentation}
      event.teams.each do |item|
        csv << [
          item.name,
          item.submission.app_name,
          item.division_name,
          item.submission.percent_complete,
          item.submission.pitch_presentation_url,
        ]
      end
    end
  end

  def broadcast(job, profile)
    channel = "jobs:#{profile.class.name}:#{profile.id}"
    data = {
      status: job.status,
      job_id: job.job_id,
    }

    if job.status == "complete"
      export = profile.exports.find_by(job_id: job.job_id)

      data.merge!({
        filename: export["file"],
        url: export.file_url,
        update_url: send(
          "#{profile.account.scope_name}_export_download_path",
          export
        ),
      })
    end

    ActionCable.server.broadcast(channel, data)
  end
end
