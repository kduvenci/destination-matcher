class RenameImageUrlToPhotoOnAccommodations < ActiveRecord::Migration[5.2]
  def change
    rename_column :accommodations, :image_url, :photo
  end
end
