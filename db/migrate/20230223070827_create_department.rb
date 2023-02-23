class CreateDepartment < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :departments, id: :uuid do |t|
      t.string :name, null: false
      t.belongs_to :customer, null: false, foreign_key: true, type: :uuid, index: { algorithm: :concurrently }

      t.timestamps
    end
  end
end
