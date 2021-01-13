class TokenController < ApplicationController
  # include Devise::RegistrationsController

  SECRET_ACCESS = 'qwerty12345'
  ALGORITHM_ACCESS = 'HS512'

  SECRET_REFRESH = 'asdfgh12345'
  ALGORITHM_REFRESH = 'HS256'

  def sing_up
    user = User.new(user_params)
    token = JWT.encode({
      user_email: params[:email],
      exp: Time.now.to_i + 120
    }, SECRET_ACCESS, ALGORITHM_ACCESS)
    refresh_token = JWT.encode({
      user: params[:email]
    }, SECRET_REFRESH, ALGORITHM_REFRESH)
    user.refresh_token = BCrypt::Password.create(refresh_token)
    if user.save
      render json: {token: token, refresh: refresh_token, email: user[:email], msg: 'ok'}, status: 201
    else
      render json: {msg: "error"}, status: 401
    end
  end

  def refresh
    begin
      decoded = JWT.decode params[:token], SECRET_ACCESS, true, { algorithm: ALGORITHM_ACCESS } # true for validate
      render json: { msg: "токен валиден" }, status: 200
    rescue JWT::ExpiredSignature
      user = User.find_by(email: params[:email])
      refresh_token = BCrypt::Password.new(user.refresh_token)
      if refresh_token == params[:refresh]
        new_token = JWT.encode({
          user: params[:email],
          exp: Time.now.to_i + 120
        }, SECRET_ACCESS, ALGORITHM_ACCESS)
        new_refresh_token = JWT.encode({
          user: params[:email]
        }, SECRET_REFRESH, ALGORITHM_REFRESH)
        user.refresh_token = new_refresh_token
        user.save
        render json: {token: new_token, refresh: new_refresh_token, msg: 'пара токенов пересоздана'}, status: 200
      else
        render json: {msg: 'refresh token не валиден'}, status: 401
      end
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
