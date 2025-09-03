class Api::V1::Auth::SessionsController < Api::V1::ApiController
  skip_before_action :authenticate_user!, only: [:create]
  skip_before_action :ensure_organization_member, only: [:create]

  def create
    user = User.find_by(email: params[:email])
    
    if user&.valid_password?(params[:password]) && user.active?
      # JWTトークンを手動で生成
      payload = user.jwt_payload
      token = JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key || '7a18eba7e4e2ad98a4303a08b795c5516feae0981a122c6a64fcfc2966823db7')
      
      render json: {
        user: serialize_user(user),
        token: token
      }
    else
      render json: {
        error: {
          code: 'UNAUTHORIZED',
          message: 'メールアドレスまたはパスワードが正しくありません'
        }
      }, status: :unauthorized
    end
  end

  def destroy
    sign_out(current_user)
    render json: { message: 'ログアウトしました' }
  end

  def me
    render json: serialize_user(current_user)
  end

  private

  def serialize_user(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      display_name: user.display_name,
      job_title: user.job_title,
      role: user.role,
      organization: {
        id: user.organization.id,
        name: user.organization.name
      },
      department: user.department&.name,
      stats: {
        sent_feedbacks_count: user.sent_feedbacks_count,
        received_feedbacks_count: user.received_feedbacks_count,
        positivity_score: user.positivity_score
      }
    }
  end
end