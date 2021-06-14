# frozen_string_literal: true

class API::Notifications::UnreadController < API::BaseController
  def index
    checked_unread_notifications = current_user.notifications.checked_unreads
    checked_unread_notifications.each do |notification|
      notification_path = notification.notified_path
      model = notification.notified_model
      id = notification.notified_id
      comments = model.find(id).comments
      next unless comments.pluck(:user_id).include?(notification.sender.id)

      latest_notification = current_user.notifications.unreads.where(path: notification_path).maximum(:created_at)
      new_message = notification.message.gsub(/を確認しました。/, 'の確認とコメントをしました。')
      notification.update(message: new_message, kind: 'check_and_comment', created_at: latest_notification + 3)
    end
    @notifications = if params[:page]
                       current_user.notifications
                                   .unreads_with_avatar
                                   .order(created_at: :desc)
                                   .page(params[:page])
                     else
                       current_user.notifications.unreads_with_avatar
                     end
    render template: 'api/notifications/index'
  end
end
