class DeliveriesCompaniesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :deliveries, :companies do |t|
      t.index :delivery_id
      t.index :company_id
    end
  end
end
