class AddCustomerReferenceToUsers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :users, :customer, type: :uuid, index: { algorithm: :concurrently }
    add_foreign_key :users, :customers, validate: false
  end
end
