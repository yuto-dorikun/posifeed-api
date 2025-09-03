class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  belongs_to :user, optional: true

  self.table_name = 'jwt_denylists'

  # Clean up expired tokens periodically
  scope :expired, -> { where('exp < ?', Time.current) }

  def self.cleanup_expired
    expired.delete_all
  end
end