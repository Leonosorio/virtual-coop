class HomeController < ApplicationController
  def index
    @total_clients = Client.count
    @active_clients = Client.where(status: true).count
    @blocked_clients = Client.where(status: false).count
    @total_payments = Payment.count

    @total_credit = Payment.joins(:payment_type)
                           .where(payment_types: { name: ["Crédito", "Credito"] })
                           .sum(:amount)

    @total_debit = Payment.joins(:payment_type)
                          .where(payment_types: { name: ["Débito", "Debito"] })
                          .sum(:amount)

    @balance = @total_credit - @total_debit

    @recent_payments = Payment.includes(:client, :payment_type)
                              .order(created_at: :desc)
                              .limit(5)
  end
end