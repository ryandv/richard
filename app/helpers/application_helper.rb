module ApplicationHelper

  def format_as_minutes(seconds)
    return "" if seconds.nil?
    "#{(seconds / 60).ceil} minutes"
  end

  def action_buttons
    queue_transaction = current_user ? QueueTransaction.next_for_user(current_user) : nil
    queue_size = QueueTransaction.queue_size

    if queue_transaction.nil?
      if queue_size == 0
        button_name = "Run Gorgon"
      else
        button_name = "Start Waiting"
      end

      button_path = queue_transactions_path

    elsif queue_transaction.waiting?
      button_name = "Stop Waiting"
      button_path = cancel_queue_transactions_path

    elsif queue_transaction.pending?
      button_name = "Run Gorgon"
      button_path = run_queue_transactions_path

    elsif queue_transaction.running?
      button_name = "Finish"
      button_path = finish_queue_transactions_path
    end

    button do
      button_to(button_name, button_path, method: :post, class: "btn btn-primary btn-block")
    end
  end

  def force_release_button
    first_user = QueueTransaction.first_in_queue.try(:user)

    if first_user.present? && first_user != current_user
      button do
        button_to("Force Release", force_release_queue_transaction_path(first_user), {
          method: :put,
          class: "btn btn-danger btn-block",
          onclick: "return confirm('Are you sure you want to Force Release #{first_user.name}?')"
        })
      end
    end
  end

  def logged_in?
    !!current_user
  end

  def flash_json
    flash.to_hash.to_json
  end

private

  def button
    "<li class=\"button\">#{yield}</li>".html_safe
  end
end
