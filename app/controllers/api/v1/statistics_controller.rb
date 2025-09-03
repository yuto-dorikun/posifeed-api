class Api::V1::StatisticsController < ApplicationController
  # 認証をスキップして誰でもアクセス可能にする
  
  def index
    period = params[:period] || '30d'
    
    # 期間の設定
    case period
    when '7d'
      start_date = 7.days.ago
    when '30d'
      start_date = 30.days.ago
    when '90d'
      start_date = 90.days.ago
    else
      start_date = nil
    end

    # 基本統計
    total_feedbacks = Feedback.count
    total_users = User.active.count
    
    # 期間内のフィードバック
    feedbacks_scope = start_date ? Feedback.where('feedbacks.created_at >= ?', start_date) : Feedback.all
    
    # カテゴリ別統計
    feedbacks_by_category = feedbacks_scope.group(:category).count
    
    # 月間統計
    feedbacks_this_month = Feedback.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    feedbacks_last_month = Feedback.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
    
    # 上位送信者（期間内）
    sender_counts = feedbacks_scope
      .joins(:sender)
      .group('users.id', 'users.last_name', 'users.first_name')
      .count('feedbacks.id')
    
    top_senders = sender_counts
      .sort_by { |_key, count| -count }
      .first(5)
      .map { |key, count| { id: key.first, name: "#{key[1]} #{key[2]}", count: count } }
    
    # 上位受信者（期間内）
    receiver_counts = feedbacks_scope
      .joins(:receiver)
      .group('users.id', 'users.last_name', 'users.first_name')
      .count('feedbacks.id')
    
    top_receivers = receiver_counts
      .sort_by { |_key, count| -count }
      .first(5)
      .map { |key, count| { id: key.first, name: "#{key[1]} #{key[2]}", count: count } }
    
    # トレンド（過去14日）
    feedback_trends = (0..13).map do |days_ago|
      date = days_ago.days.ago.to_date
      count = Feedback.where(created_at: date.beginning_of_day..date.end_of_day).count
      { date: date.to_s, count: count }
    end.reverse
    
    # 部署別統計
    department_stats = Department.joins(users: :received_feedbacks)
      .where('feedbacks.created_at >= ?', start_date || 1.year.ago)
      .group('departments.name')
      .count('feedbacks.id')
      .map do |name, count|
        period_total = feedbacks_scope.count
        percentage = period_total > 0 ? ((count.to_f / period_total) * 100).round : 0
        { name: name, count: count, percentage: percentage }
      end
      .sort_by { |stat| -stat[:count] }

    render json: {
      totalFeedbacks: total_feedbacks,
      totalUsers: total_users,
      feedbacksByCategory: {
        gratitude: feedbacks_by_category['gratitude'] || 0,
        admiration: feedbacks_by_category['admiration'] || 0,
        appreciation: feedbacks_by_category['appreciation'] || 0,
        respect: feedbacks_by_category['respect'] || 0
      },
      feedbacksThisMonth: feedbacks_this_month,
      feedbacksLastMonth: feedbacks_last_month,
      topSenders: top_senders,
      topReceivers: top_receivers,
      feedbackTrends: feedback_trends,
      departmentStats: department_stats
    }
  rescue StandardError => e
    render json: { error: '統計データの取得に失敗しました', details: e.message }, status: :internal_server_error
  end
end