class QueueTransactionsController < ApplicationController

  def index
    @queue = QueueTransaction.where(:is_complete => false).order("waiting_start_at asc").load
  end

  def current
    qt = QueueTransaction.connection.select_all("
        select u.email, qt.status,
        case qt.status
          when '#{QueueTransaction::RUNNING}' then round(extract(epoch from now() - qt.running_start_at)/60)
          when '#{QueueTransaction::WAITING}' then round(extract(epoch from now() - qt.waiting_start_at)/60)
          when '#{QueueTransaction::PENDING}' then round(extract(epoch from now() - qt.pending_start_at)/60)
        end as duration,
        case qt.status
        when '#{QueueTransaction::RUNNING}' then round(extract(epoch from now() - qt.running_start_at)/60) else null end as blocking_duration
        from queue_transactions qt
        left join users u on qt.user_id = u.id
        where qt.is_complete is false
        order by qt.waiting_start_at"
    )
    render json: qt
  end

  def action_status
    queue_transaction = current_user ? current_user.current_queue_transaction : nil
    queue_size = QueueTransaction.queue_size

    if queue_transaction.nil?
        if queue_size == 0
          render json:       'run'
        else
          render json: 'start_waiting'
        end
    elsif queue_transaction.waiting?
      render json: 'stop_waiting'
    elsif queue_transaction.pending?
      render json: 'run'
    elsif queue_transaction.running?
      render json: 'finish'
    end
  end

  def create
    if QueueTransaction.where(is_complete: false).count == 0
      now = Time.now
      QueueTransaction.create\
        user_id: current_user.id,
        waiting_start_at: now,
        pending_start_at: now,
        running_start_at: now,
        is_complete: false,
        status: QueueTransaction::RUNNING
    else
      QueueTransaction.create user_id: current_user.id, waiting_start_at: Time.now, is_complete: false
    end

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    end

    redirect_to root_path
  end

  def cancel
    load_queue_transaction
    @queue_transaction.update_attributes cancelled_at: Time.now, is_complete: true, status: QueueTransaction::CANCELLED

    first_in_queue = QueueTransaction.get_first_in_queue
    next_in_queue = QueueTransaction.get_next_in_queue(@queue_transaction)
    if first_in_queue == next_in_queue
      next_in_queue.update_attributes pending_start_at: Time.now, status: QueueTransaction::PENDING
      UserMailer.notify_user_of_turn(next_in_queue)
    end

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    end
#TODO - remove the redirects??
    redirect_to root_path
  end

  def run
    load_queue_transaction

    @queue_transaction.update_attributes running_start_at: Time.now, status: QueueTransaction::RUNNING

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    else
      Gorgon.run(current_user.id)
    end

    redirect_to root_path
  end

  def finish
    load_queue_transaction
    @queue_transaction.update_attributes finished_at: Time.now, is_complete: true, status: QueueTransaction::COMPLETE
    transaction = QueueTransaction.get_first_in_queue
    if transaction
      transaction.update_attributes pending_start_at: Time.now, status: QueueTransaction::PENDING
      UserMailer.notify_user_of_turn(transaction)
    end

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    else
      Gorgon.finish
    end

    redirect_to root_path
  end

  def pending_next
    if current_user.current_queue_transaction && current_user.current_queue_transaction.status == QueueTransaction::PENDING
      next_in_line = true
    else
      next_in_line = false
    end

    render json: {next_in_line: next_in_line}
  end

  def force_release
    load_queue_transaction
    @queue_transaction.update_attributes force_release_at: Time.now, is_complete: true, status: QueueTransaction::COMPLETE
    UserMailer.notify_release(@queue_transaction)
    transaction = QueueTransaction.get_first_in_queue
    if transaction
      transaction.update_attributes pending_start_at: Time.now, status: QueueTransaction::PENDING
      UserMailer.notify_user_of_turn(transaction)
    end

    redirect_to root_path
  end

private
  def load_queue_transaction
    @queue_transaction = QueueTransaction.find(params[:id])
  end
end
