require "./app/models/certificate_recipient"
require "./app/technovation/override_certificate"

module DropLowestScores
  def self.call(submission, logger_opt = nil)
    logger = Logger.new(logger_opt)

    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end

    logger.info "----------------------------------------"

    if submission.lowest_score_dropped?
      logger.info "SKIP already dropped score for Submission##{submission.id}"
      return false
    else
      minimum_score = submission.semifinals_complete_submission_scores.min_by(&:total)

      logger.info "FIND lowest complete semifinals score for Submission##{submission.id}"
      logger.info "Team ID##{submission.team_id}"
      logger.info "SF Average: #{submission.semifinals_average_score}"
      logger.info submission.semifinals_complete_submission_scores.map(&:total).sort

      account = minimum_score.judge_profile.account
      certificate_recipient = CertificateRecipient.new(account)

      logger.info "PRESERVE judge certificate - #{certificate_recipient.string_certificate_type} - Judge Account##{account.id}"

      OverrideCertificate.(account, certificate_recipient.certificate_type)

      logger.warn "DROP lowest score"
      logger.info minimum_score.total

      submission.lowest_score_dropped!
      minimum_score.destroy

      logger.info "Updated SF Average: #{submission.reload.semifinals_average_score}"

      certificate_recipient = CertificateRecipient.new(account.reload)
      logger.info "Reloaded judge certificate - #{certificate_recipient.string_certificate_type} - Judge Account##{account.id}"
    end
  end
end