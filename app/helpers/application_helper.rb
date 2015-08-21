module ApplicationHelper

  def format_as_minutes(seconds)
    return "" if seconds.nil?
    "#{(seconds / 60).ceil} minutes"
  end

  def action_buttons
    queue_transaction = GorgonQueue.transaction_for_user(current_user)

    if queue_transaction.nil?
      if GorgonQueue.size == 0
        button_name = "Grab Richard"
      else
        button_name = "Start Waiting"
      end

      button_path = grab_path

    elsif queue_transaction.waiting?
      button_name = "Stop Waiting"
      button_path = release_path

    elsif queue_transaction.running?
      button_name = "Finish"
      button_path = release_path
    end

    button do
      button_to(button_name, button_path, method: :post, class: "btn btn-primary btn-block")
    end
  end

  def force_release_button
    next_user = GorgonQueue.next_user

    if next_user.present? && next_user != current_user
      button do
        button_to("Force Release", force_release_path(next_user), {
          method: :post,
          class: "btn btn-danger btn-block",
          onclick: "return confirm('Are you sure you want to Force Release #{next_user.name}?')"
        })
      end
    end
  end

  def logged_in?
    !!current_user
  end

  def flash_json
    flash.now.to_hash.to_json
  end

private

  def button
    "<li class=\"button\">#{yield}</li>".html_safe
  end
end
