Potionstore::Application.config.middleware.use ExceptionNotification::Rack,
:email => {
  :email_prefix => "[STORE]",
  :sender_address => %{"Potion Store" <store@domain.com>},
  :exception_recipients => %{storecrash@domain.com}
}

class ActionDispatch::DebugExceptions
  alias_method :old_log_error, :log_error
  def log_error(env, wrapper)
    if wrapper.exception.is_a?  ActionController::RoutingError
      return
    else
      old_log_error env, wrapper
    end
  end
end