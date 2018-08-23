class AddJobQualificationToErpCorporatorsCorporators < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_corporators_corporators, :job_qualification, :text
  end
end
