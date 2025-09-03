class Api::V1::HealthController < ApplicationController
  def show
    render json: {
      status: 'ok',
      database: database_status,
      redis: redis_status,
      timestamp: Time.current,
      environment: Rails.env,
      version: '1.0.0'
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue
    'disconnected'
  end

  def redis_status
    Redis.current.ping == 'PONG' ? 'connected' : 'disconnected'
  rescue
    'disconnected'
  end
end