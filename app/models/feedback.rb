class Feedback < ApplicationRecord
  belongs_to :sender, class_name: 'User', counter_cache: :sent_feedbacks_count
  belongs_to :receiver, class_name: 'User', counter_cache: :received_feedbacks_count
  belongs_to :organization
  has_many :feedback_reactions, dependent: :destroy

  enum category: { gratitude: 0, admiration: 1, appreciation: 2, respect: 3 }

  validates :message, presence: true, length: { maximum: 1000 }
  validates :category, inclusion: { in: categories.keys }
  validate :no_self_feedback
  validate :same_organization

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(cat) { where(category: cat) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def editable?
    created_at > 24.hours.ago
  end

  def category_emoji
    case category
    when 'gratitude'
      '🙏'
    when 'admiration'
      '✨'
    when 'appreciation'
      '💪'
    when 'respect'
      '👏'
    end
  end

  def category_name_ja
    case category
    when 'gratitude'
      'ありがとう'
    when 'admiration'
      'すごい！'
    when 'appreciation'
      'お疲れさま'
    when 'respect'
      'さすが'
    end
  end

  private

  def no_self_feedback
    errors.add(:receiver, '自分にはフィードバックを送信できません') if sender_id == receiver_id
  end

  def same_organization
    return unless sender && receiver
    
    unless sender.same_organization?(receiver)
      errors.add(:receiver, '同じ組織のメンバーにのみフィードバックを送信できます')
    end
  end
end