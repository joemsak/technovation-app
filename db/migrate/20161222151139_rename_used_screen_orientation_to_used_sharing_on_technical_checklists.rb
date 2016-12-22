class RenameUsedScreenOrientationToUsedSharingOnTechnicalChecklists < ActiveRecord::Migration
  def change
    rename_column :technical_checklists, :used_screen_orientation, :used_sharing
    rename_column :technical_checklists, :used_screen_orientation_explanation, :used_sharing_explanation
  end
end
