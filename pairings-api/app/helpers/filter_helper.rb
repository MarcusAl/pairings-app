module FilterHelper
  def toggle_filter(param_key, value)
    current = Array(params[param_key])
    if current.include?(value)
      current - [value]
    else
      current + [value]
    end
  end
end
