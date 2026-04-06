class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :document
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :account_number
      t.boolean :status
      t.references :document_type, null: false, foreign_key: true
      t.references :account_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
