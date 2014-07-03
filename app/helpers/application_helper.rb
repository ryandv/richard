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
          button_to("Run Gorgon", queue_transactions_path, :method => :post, :class => "btn btn-primary")
        else
          button_to("Start Waiting", queue_transactions_path, :method => :post, :class => "btn btn-primary")
        end
      end
    elsif queue_transaction.waiting?
      button do
        button_to("Stop Waiting", cancel_queue_transaction_path(queue_transaction), :method => :put, :class => "btn btn-primary")
      end
    elsif queue_transaction.pending?
      button do
        button_to("Run Gorgon", run_queue_transaction_path(queue_transaction), :method => :put, :class => "btn btn-primary")
      end
    elsif queue_transaction.running?
      button do
        button_to("Finish", finish_queue_transaction_path(queue_transaction), :method => :put, :class => "btn btn-primary")
      end
    end
  end

  def button
    "<li class=\"button\">#{yield}</li>".html_safe
  end
end
