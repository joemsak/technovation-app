module CanRemoveTeamMember
  def self.call(account, member)
    account.admin_profile or
      member.onboarding? or
        account.id == member.account_id
  end
end