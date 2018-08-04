class AddCustomOrderToErpCorporatorsCorporators < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_corporators_corporators, :custom_order, :integer
  end
end
