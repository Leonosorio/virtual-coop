class SessionsController < ApplicationController
  layout "auth"

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bienvenido a VirtualCoop."
    else
      flash.now[:alert] = "Correo o contraseña incorrectos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Sesión cerrada correctamente."
  end
end