class CreateErpCorporatorsCorporators < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_corporators_corporators do |t|
      t.string :image_url
      t.string :corp_type
      t.string :code
      t.string :name
      t.string :phone
      t.string :hotline
      t.string :address
      t.string :tax_code
      t.datetime :birthday
      t.string :email
      t.string :gender
      t.text :note
      t.string :fax
      t.string :website
      t.references :creator, index: true, references: :erp_users
      t.references :parent, index: true, references: :erp_corporators_corporators
      t.references :country, index: true, references: :erp_areas_countries
      t.references :state, index: true, references: :erp_areas_states
      t.references :district, index: true, references: :erp_areas_districts
      t.string :status
      t.text :cache_search

      t.timestamps
    end
  end
end
