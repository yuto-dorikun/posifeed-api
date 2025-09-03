class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :departments, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  validates :name, presence: true
  validates :domain, uniqueness: true, allow_blank: true

  scope :active, -> { where(active: true) }

  def active_users
    users.where(active: true)
  end

  def active_departments
    departments.where(active: true)
  end
end