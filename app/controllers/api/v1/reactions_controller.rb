class Api::V1::ReactionsController < Api::V1::ApiController
  before_action :set_feedback

  def create
    # 既存のリアクションをチェック
    existing_reaction = @feedback.feedback_reactions.find_by(user: current_user)
    
    if existing_reaction
      # 既存のリアクションを更新
      if existing_reaction.update(reaction_params)
        render json: {
          message: 'リアクションを更新しました',
          reaction: serialize_reaction(existing_reaction)
        }
      else
        render json: {
          error: {
            code: 'VALIDATION_ERROR',
            message: 'リアクションの更新に失敗しました',
            details: existing_reaction.errors.messages
          }
        }, status: :unprocessable_entity
      end
    else
      # 新しいリアクションを作成
      reaction = @feedback.feedback_reactions.build(reaction_params)
      reaction.user = current_user
      
      if reaction.save
        render json: {
          message: 'リアクションを追加しました',
          reaction: serialize_reaction(reaction)
        }, status: :created
      else
        render json: {
          error: {
            code: 'VALIDATION_ERROR',
            message: 'リアクションの追加に失敗しました',
            details: reaction.errors.messages
          }
        }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    reaction = @feedback.feedback_reactions.find_by(user: current_user)
    
    if reaction
      reaction.destroy
      render json: { message: 'リアクションを削除しました' }
    else
      render json: {
        error: {
          code: 'NOT_FOUND',
          message: 'リアクションが見つかりません'
        }
      }, status: :not_found
    end
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:feedback_id])
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end

  def serialize_reaction(reaction)
    {
      id: reaction.id,
      reaction_type: reaction.reaction_type,
      reaction_name: reaction.reaction_name_ja,
      reaction_emoji: reaction.reaction_emoji,
      user: {
        id: reaction.user.id,
        display_name: reaction.user.display_name
      },
      created_at: reaction.created_at
    }
  end
end