class Api::V1::FeedbacksController < Api::V1::ApiController
  before_action :set_feedback, only: [:show, :update, :destroy, :read]

  def index
    feedbacks = current_user.organization.feedbacks
                           .includes(:sender, :receiver, :feedback_reactions)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(params[:per_page] || 20)

    render json: {
      feedbacks: feedbacks.map { |feedback| serialize_feedback(feedback) },
      meta: pagination_meta(feedbacks)
    }
  end

  def received
    feedbacks = current_user.received_feedbacks
                           .includes(:sender, :feedback_reactions)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(params[:per_page] || 20)

    render json: {
      feedbacks: feedbacks.map { |feedback| serialize_feedback(feedback) },
      meta: pagination_meta(feedbacks)
    }
  end

  def sent
    feedbacks = current_user.sent_feedbacks
                           .includes(:receiver, :feedback_reactions)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(params[:per_page] || 20)

    render json: {
      feedbacks: feedbacks.map { |feedback| serialize_feedback(feedback) },
      meta: pagination_meta(feedbacks)
    }
  end

  def show
    render json: serialize_feedback(@feedback)
  end

  def create
    feedback = current_user.organization.feedbacks.build(feedback_params)
    feedback.sender = current_user

    if feedback.save
      render json: serialize_feedback(feedback), status: :created
    else
      render json: {
        error: {
          code: 'VALIDATION_ERROR',
          message: 'フィードバックの作成に失敗しました',
          details: feedback.errors.messages
        }
      }, status: :unprocessable_entity
    end
  end

  def update
    if @feedback.editable? && @feedback.sender == current_user
      if @feedback.update(feedback_params.except(:receiver_id))
        render json: serialize_feedback(@feedback)
      else
        render json: {
          error: {
            code: 'VALIDATION_ERROR',
            message: 'フィードバックの更新に失敗しました',
            details: @feedback.errors.messages
          }
        }, status: :unprocessable_entity
      end
    else
      render json: {
        error: {
          code: 'FORBIDDEN',
          message: '編集できません（24時間以内または権限なし）'
        }
      }, status: :forbidden
    end
  end

  def destroy
    if @feedback.sender == current_user || current_user.admin?
      @feedback.destroy
      render json: { message: 'フィードバックを削除しました' }
    else
      render json: {
        error: {
          code: 'FORBIDDEN',
          message: '削除権限がありません'
        }
      }, status: :forbidden
    end
  end

  def read
    if @feedback.receiver == current_user
      @feedback.mark_as_read!
      render json: serialize_feedback(@feedback)
    else
      render json: {
        error: {
          code: 'FORBIDDEN',
          message: '既読操作の権限がありません'
        }
      }, status: :forbidden
    end
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def feedback_params
    params.require(:feedback).permit(:receiver_id, :category, :message, :is_anonymous)
  end

  def serialize_feedback(feedback)
    {
      id: feedback.id,
      message: feedback.message,
      category: feedback.category,
      category_name: feedback.category_name_ja,
      category_emoji: feedback.category_emoji,
      is_anonymous: feedback.is_anonymous,
      reactions_count: feedback.reactions_count,
      read_at: feedback.read_at,
      created_at: feedback.created_at,
      updated_at: feedback.updated_at,
      editable: feedback.editable?,
      sender: feedback.is_anonymous? ? nil : serialize_user_summary(feedback.sender),
      receiver: serialize_user_summary(feedback.receiver)
    }
  end

  def serialize_user_summary(user)
    {
      id: user.id,
      display_name: user.display_name,
      job_title: user.job_title,
      department: user.department&.name
    }
  end
end