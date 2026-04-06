class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :payment_type

  validates :client_id, presence: true
  validates :payment_type_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end