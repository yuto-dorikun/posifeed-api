class Api::V1::ApiController < ApplicationController
  include Pundit::Authorization if defined?(Pundit)
  
  before_action :authenticate_user!
  before_action :ensure_organization_member

  rescue_from Pundit::NotAuthorizedError, with: :forbidden if defined?(Pundit)
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def current_user
    @current_user ||= warden.authenticate!(:jwt)
  end

  def ensure_organization_member
    render json: { error: { code: 'FORBIDDEN', message: '組織メンバーではありません' } }, 
           status: :forbidden unless current_user&.active?
  end

  def forbidden(exception)
    render json: {
      error: {
        code: 'FORBIDDEN',
        message: 'この操作は許可されていません'
      }
    }, status: :forbidden
  end

  def not_found(exception)
    render json: {
      error: {
        code: 'NOT_FOUND',
        message: 'リソースが見つかりません'
      }
    }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: {
      error: {
        code: 'VALIDATION_ERROR',
        message: 'バリデーションエラーが発生しました',
        details: exception.record.errors.messages
      }
    }, status: :unprocessable_entity
  end

  def pagination_meta(collection)
    if collection.respond_to?(:current_page)
      {
        current_page: collection.current_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count,
        per_page: collection.limit_value
      }
    else
      {}
    end
  end
end