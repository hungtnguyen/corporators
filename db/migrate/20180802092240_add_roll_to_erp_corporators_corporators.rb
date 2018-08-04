class AddRollToErpCorporatorsCorporators < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_corporators_corporators, :roll, :string
  end
end
