class Department < ApplicationRecord
  belongs_to :organization
  belongs_to :parent, class_name: 'Department', optional: true
  has_many :children, class_name: 'Department', foreign_key: 'parent_id', dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :organization_id }

  scope :active, -> { where(active: true) }
  scope :root_departments, -> { where(parent: nil) }

  def full_name
    return name unless parent
    "#{parent.name} / #{name}"
  end

  def active_users
    users.where(active: true)
  end
end