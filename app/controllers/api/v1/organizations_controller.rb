class Api::V1::OrganizationsController < Api::V1::ApiController
  
  def show
    render json: serialize_organization(current_user.organization)
  end

  def users
    users = current_user.organization.users
                       .active
                       .includes(:department)
                       .order(:first_name, :last_name)

    render json: {
      organization: serialize_organization(current_user.organization),
      users: users.map { |user| serialize_user_summary(user) }
    }
  end

  private

  def serialize_organization(organization)
    {
      id: organization.id,
      name: organization.name,
      description: organization.description,
      domain: organization.domain,
      active: organization.active,
      stats: {
        total_users: organization.active_users.count,
        total_feedbacks: organization.feedbacks.count,
        departments_count: organization.active_departments.count
      },
      created_at: organization.created_at,
      updated_at: organization.updated_at
    }
  end

  def serialize_user_summary(user)
    {
      id: user.id,
      display_name: user.display_name,
      job_title: user.job_title,
      department: user.department&.name,
      role: user.role,
      stats: {
        sent_feedbacks_count: user.sent_feedbacks_count,
        received_feedbacks_count: user.received_feedbacks_count,
        positivity_score: user.positivity_score
      }
    }
  end
end