# frozen_string_literal: true

class CheckCallbacks
  def after_create(check)
    if check.sender != check.reciever
      NotificationFacade.checked(check)
    end
  end
end
