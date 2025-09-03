# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.env.production? ? ['https://*.vercel.app', 'https://*.railway.app'] : ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:5174', 'http://100.64.1.16:5173', 'http://100.66.138.69:5173', 'http://100.115.6.63:5173']
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
