class AddDemoVideoLinkToTeamSubmissions < ActiveRecord::Migration
  def change
    add_column :team_submissions, :demo_video_link, :string
  end
end
