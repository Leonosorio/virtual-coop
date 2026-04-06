class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.text :description
      t.references :client, null: false, foreign_key: true
      t.references :payment_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
