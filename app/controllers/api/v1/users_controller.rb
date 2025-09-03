class Api::V1::UsersController < Api::V1::ApiController
  before_action :set_user, only: [:show, :update, :stats]

  def index
    users = current_user.organization.users
                       .active
                       .includes(:department)
                       .order(:first_name, :last_name)

    render json: {
      users: users.map { |user| serialize_user_summary(user) }
    }
  end

  def show
    render json: serialize_user(@user)
  end

  def update
    if @user == current_user
      if @user.update(user_params)
        render json: serialize_user(@user)
      else
        render json: {
          error: {
            code: 'VALIDATION_ERROR',
            message: 'プロフィールの更新に失敗しました',
            details: @user.errors.messages
          }
        }, status: :unprocessable_entity
      end
    else
      render json: {
        error: {
          code: 'FORBIDDEN',
          message: '他のユーザーのプロフィールは編集できません'
        }
      }, status: :forbidden
    end
  end

  def stats
    # 期間指定（デフォルト：過去30日）
    period = params[:period] || '30'
    start_date = period.to_i.days.ago

    # 統計データを計算
    sent_feedbacks = @user.sent_feedbacks.where('created_at >= ?', start_date)
    received_feedbacks = @user.received_feedbacks.where('created_at >= ?', start_date)

    # カテゴリ別集計
    sent_by_category = sent_feedbacks.group(:category).count
    received_by_category = received_feedbacks.group(:category).count

    # 週ごとの推移（過去4週間）
    weekly_stats = []
    4.times do |i|
      week_start = (3 - i).weeks.ago.beginning_of_week
      week_end = week_start.end_of_week
      
      sent_count = @user.sent_feedbacks.where(created_at: week_start..week_end).count
      received_count = @user.received_feedbacks.where(created_at: week_start..week_end).count
      
      weekly_stats << {
        week: week_start.strftime('%Y年%m月%d日'),
        sent: sent_count,
        received: received_count,
        positivity_score: calculate_weekly_score(sent_count, received_count)
      }
    end

    render json: {
      user: serialize_user_summary(@user),
      period_stats: {
        period: "#{period}日間",
        sent_total: sent_feedbacks.count,
        received_total: received_feedbacks.count,
        sent_by_category: format_category_stats(sent_by_category),
        received_by_category: format_category_stats(received_by_category)
      },
      weekly_trends: weekly_stats,
      overall_stats: {
        total_sent: @user.sent_feedbacks_count,
        total_received: @user.received_feedbacks_count,
        positivity_score: @user.positivity_score
      }
    }
  end

  private

  def set_user
    @user = current_user.organization.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :display_name, :job_title)
  end

  def serialize_user(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      display_name: user.display_name,
      job_title: user.job_title,
      role: user.role,
      active: user.active,
      organization: {
        id: user.organization.id,
        name: user.organization.name
      },
      department: user.department ? {
        id: user.department.id,
        name: user.department.name
      } : nil,
      stats: {
        sent_feedbacks_count: user.sent_feedbacks_count,
        received_feedbacks_count: user.received_feedbacks_count,
        positivity_score: user.positivity_score
      },
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end

  def serialize_user_summary(user)
    {
      id: user.id,
      display_name: user.display_name,
      job_title: user.job_title,
      department: user.department&.name,
      stats: {
        sent_feedbacks_count: user.sent_feedbacks_count,
        received_feedbacks_count: user.received_feedbacks_count,
        positivity_score: user.positivity_score
      }
    }
  end

  def format_category_stats(stats)
    formatted = {}
    Feedback.categories.each do |key, value|
      formatted[key] = {
        count: stats[key] || 0,
        name: Feedback.new(category: key).category_name_ja,
        emoji: Feedback.new(category: key).category_emoji
      }
    end
    formatted
  end

  def calculate_weekly_score(sent_count, received_count)
    sent = sent_count * 0.4
    received = received_count * 0.6
    [(sent + received), 100].min.round(1)
  end
end