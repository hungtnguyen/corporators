class AddProfileAlbumIdToErpCorporatorsCorporators < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_corporators_corporators, :profile_album_id, :integer
  end
end
