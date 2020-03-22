json.extract! company, :id, :name, :description, :phone, :url, :created_at, :updated_at
json.url company_url(company, format: :json)
