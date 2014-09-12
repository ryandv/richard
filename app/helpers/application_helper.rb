module ApplicationHelper

  def format_as_minutes(seconds)
    return "" if seconds.nil?
    "#{(seconds / 60).ceil} minutes"
  end

  def action_buttons
    queue_transaction = current_user ? current_user.current_queue_transaction : nil
    queue_size = QueueTransaction.queue_size

    if queue_transaction.nil?
      button do
        if queue_size == 0
          button_to("Run Gorgon", queue_transactions_path, :method => :post, :class => "btn btn-primary btn-block")
        else
          button_to("Start Waiting", queue_transactions_path, :method => :post, :class => "btn btn-primary btn-block")
        end
      end
    elsif queue_transaction.waiting?
      button do
        button_to("Stop Waiting", cancel_queue_transaction_path(queue_transaction), :method => :put, :class => "btn btn-primary btn-block")
      end
    elsif queue_transaction.pending?
      button do
        button_to("Run Gorgon", run_queue_transaction_path(queue_transaction), :method => :put, :class => "btn btn-primary btn-block")
      end
    elsif queue_transaction.running?
      button do
        button_to("Finish", finish_queue_transaction_path(queue_transaction), :method => :put, :class => "btn btn-primary btn-block")
      end
    end
  end

  def force_release_button
    queue_transaction = QueueTransaction.where(is_complete: false).order("waiting_start_at asc").first
      if queue_transaction && queue_transaction.user_id != current_user.id
        button do
          button_to("Force Release", force_release_queue_transaction_path(queue_transaction), :method => :put, :class => "btn btn-danger btn-block", :onclick => "return confirm('Are you sure you want to Force Release?')")
        end
    end
  end

  private

  def button
    "<li class=\"button\">#{yield}</li>".html_safe
  end
end
