class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  respond_to :json

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { error: 'Token missing' }, status: :unauthorized
      return
    end

    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.jwt_secret_key, true, { algorithm: 'HS256' })
      user_id = decoded_token[0]['user_id']
      @current_user = User.find_by(id: user_id)
      
      if @current_user.nil?
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    rescue JWT::DecodeError => e
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :organization_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :display_name, :job_title])
  end
end
