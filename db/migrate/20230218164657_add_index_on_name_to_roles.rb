class AddIndexOnNameToRoles < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :roles, :name, algorithm: :concurrently
  end
end
