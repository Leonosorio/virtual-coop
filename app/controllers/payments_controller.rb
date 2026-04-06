class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update destroy]
  before_action :load_form_collections, only: %i[new create edit update]

  # GET /payments
  def index
    if params[:client_id].present?
      @client = Client.find(params[:client_id])
      @payments = @client.payments.includes(:payment_type, :client).order(created_at: :desc)
    else
      @payments = Payment.includes(:payment_type, :client).order(created_at: :desc)
    end
  end

  # GET /payments/1
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  def create
    @payment = Payment.new(payment_params)

    if blocked_client_selected?(@payment.client_id)
      load_form_collections
      flash.now[:alert] = "No se puede registrar un pago a un cliente bloqueado."
      render :new, status: :unprocessable_entity
      return
    end

    respond_to do |format|
      if @payment.save
        format.html { redirect_to payments_path, notice: "Pago registrado correctamente." }
        format.json { render :show, status: :created, location: @payment }
      else
        load_form_collections
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1
  def update
    if blocked_client_selected?(payment_params[:client_id])
      load_form_collections
      flash.now[:alert] = "No se puede asignar el pago a un cliente bloqueado."
      render :edit, status: :unprocessable_entity
      return
    end

    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to payments_path, notice: "Pago actualizado correctamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @payment }
      else
        load_form_collections
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  def destroy
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_path, notice: "Pago eliminado correctamente.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /payments/export
  def export
    @payments = Payment.includes(:client, :payment_type).order(created_at: :desc)

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Pagos") do |sheet|
      sheet.add_row ["Cliente", "Tipo de pago", "Cuenta", "Valor", "Descripción", "Fecha"]

      @payments.each do |payment|
        sheet.add_row [
          payment.client.full_name,
          payment.payment_type.name,
          payment.client.account_number,
          payment.amount,
          payment.description.present? ? payment.description : "Sin descripción",
          payment.created_at.strftime("%d/%m/%Y %H:%M")
        ]
      end
    end

    send_data package.to_stream.read,
              filename: "pagos_virtual_coop.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def load_form_collections
    @clients = Client.where(status: true).order(:first_name, :last_name)
    @payment_types = PaymentType.order(:name)
  end

  def payment_params
    params.require(:payment).permit(
      :client_id,
      :payment_type_id,
      :amount,
      :description
    )
  end

  def blocked_client_selected?(client_id)
    client = Client.find_by(id: client_id)
    client.present? && client.status == false
  end
end