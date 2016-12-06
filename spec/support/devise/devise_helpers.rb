module DeviseHelpers
  def resource_name
    :user
  end

  def resource_class
    User
  end

  def resource
    @resource ||= resource_class.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[resource_name]
  end
end
