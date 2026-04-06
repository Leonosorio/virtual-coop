class Client < ApplicationRecord
  belongs_to :document_type
  belongs_to :account_type
  has_many :payments

  validates :document, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone, presence: true,
                    format: { with: /\A\d+\z/, message: "solo permite números" }

  validates :account_number, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end