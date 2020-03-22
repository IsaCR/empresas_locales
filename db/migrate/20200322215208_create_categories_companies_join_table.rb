class CreateCategoriesCompaniesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :categories, :companies do |t|
      t.index :category_id
      t.index :company_id
    end
  end
end
