class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy block unblock]
  before_action :load_collections, only: %i[new create edit update]

  # GET /clients
  def index
  @clients = Client.includes(:document_type, :account_type).order(status: :desc, created_at: :desc)

  if params[:document].present?
    @clients = @clients.where("document_number ILIKE ?", "%#{params[:document]}%")
  end

  @total_clients = Client.count
  @active_clients = Client.where(status: true).count
  @blocked_clients = Client.where(status: false).count
end

  # GET /clients/1
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  def create
    @client = Client.new(client_params)
    @client.status = true if @client.status.nil?

    if @client.save
      redirect_to clients_path, notice: "Cliente registrado correctamente."
    else
      load_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1
  def update
    if @client.update(client_params)
      redirect_to clients_path, notice: "Cliente actualizado correctamente."
    else
      load_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Cliente eliminado correctamente."
  end

  def block
    @client.update(status: false)
    redirect_to clients_path, notice: "Cliente bloqueado correctamente."
  end

  def unblock
    @client.update(status: true)
    redirect_to clients_path, notice: "Cliente desbloqueado correctamente."
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def load_collections
    @document_types = DocumentType.all
    @account_types = AccountType.all
  end

  def client_params
    params.require(:client).permit(
      :document,
      :document_type_id,
      :first_name,
      :last_name,
      :email,
      :phone,
      :account_number,
      :account_type_id,
      :status
    )
  end
end