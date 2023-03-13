class CreateUserDepartments < ActiveRecord::Migration[7.0]
  def change
    create_table :user_departments, id: false do |t|
      t.uuid :user_id, null: false, foreign_key: true, index: true
      t.uuid :department_id, null: false, foreign_key: true, index: true
    end
  end
end
