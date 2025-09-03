class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  belongs_to :organization
  belongs_to :department, optional: true
  
  has_many :sent_feedbacks, class_name: 'Feedback', foreign_key: 'sender_id',
           counter_cache: :sent_feedbacks_count, dependent: :destroy
  has_many :received_feedbacks, class_name: 'Feedback', foreign_key: 'receiver_id',
           counter_cache: :received_feedbacks_count, dependent: :destroy
  has_many :feedback_reactions, dependent: :destroy

  enum role: { member: 0, admin: 1 }

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { scope: :organization_id }

  scope :active, -> { where(active: true) }

  def jwt_payload
    {
      user_id: id,
      organization_id: organization_id,
      role: role,
      exp: 1.week.from_now.to_i
    }
  end

  def display_name
    super.presence || "#{first_name} #{last_name}"
  end

  def positivity_score
    sent = sent_feedbacks_count * 0.4
    received = received_feedbacks_count * 0.6
    [(sent + received), 100].min.round(1)
  end

  def same_organization?(other_user)
    organization_id == other_user.organization_id
  end
end
