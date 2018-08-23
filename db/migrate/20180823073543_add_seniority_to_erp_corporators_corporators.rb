class AddSeniorityToErpCorporatorsCorporators < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_corporators_corporators, :seniority, :string
  end
end
