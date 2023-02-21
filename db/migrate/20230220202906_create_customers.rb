class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers, id: :uuid do |t|
      t.string :name
      t.string :currency, default: 'PLN'
      t.boolean :active?, default: true, null: false

      t.timestamps
    end
  end
end
