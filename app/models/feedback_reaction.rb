class FeedbackReaction < ApplicationRecord
  belongs_to :feedback, counter_cache: :reactions_count
  belongs_to :user

  enum reaction_type: { thanks: 0, like: 1, celebrate: 2 }

  validates :reaction_type, inclusion: { in: reaction_types.keys }
  validates :user_id, uniqueness: { scope: :feedback_id, message: 'すでにリアクション済みです' }

  def reaction_emoji
    case reaction_type
    when 'thanks'
      '🙏'
    when 'like'
      '👍'
    when 'celebrate'
      '🎉'
    end
  end

  def reaction_name_ja
    case reaction_type
    when 'thanks'
      'ありがとう'
    when 'like'
      'いいね'
    when 'celebrate'
      '祝福'
    end
  end
end