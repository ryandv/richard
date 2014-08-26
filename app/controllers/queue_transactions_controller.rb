require 'Streamer/SSE'
class QueueTransactionsController < ApplicationController
  include ActionController::Live
  Mime::Type.register "text/event-stream", :stream

  def event
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Streamer::SSE.new(response.stream)
    redis = Redis.new
    redis.subscribe('queue_transactions.update') do |on|
      on.message do |event, data|
        sse.write(data, event: 'queue_transactions.update')
      end
    end
    render nothing: true
  rescue IOError
    # Client disconnected
  ensure
    redis.quit
    sse.close
  end

  def current
    render json: current_queue_transactions
  end

  def user
    u = current_user
    render json: {email: u.email}
  end

  def create
    response.headers['Content-Type'] = 'text/javascript'

    if QueueTransaction.where(is_complete: false).count == 0
      now = Time.now
      QueueTransaction.create(user_id: current_user.id,
                              waiting_start_at: now,
                              pending_start_at: now,
                              running_start_at: now,
                              is_complete: false,
                              status: QueueTransaction::RUNNING)
    else
      QueueTransaction.create user_id: current_user.id,
                              waiting_start_at: Time.now,
                              is_complete: false,
                              status: QueueTransaction::WAITING
    end
    push_queue_transactions_update
    render nothing: true
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
    push_queue_transactions_update
    render nothing: true
  end

  def run
    load_queue_transaction
    @queue_transaction.update_attributes running_start_at: Time.now, status: QueueTransaction::RUNNING
    push_queue_transactions_update
    render nothing: true
  end

  def finish
    load_queue_transaction
    @queue_transaction.update_attributes finished_at: Time.now, is_complete: true, status: QueueTransaction::COMPLETE
    transaction = QueueTransaction.get_first_in_queue
    if transaction
      transaction.update_attributes pending_start_at: Time.now, status: QueueTransaction::PENDING
      UserMailer.notify_user_of_turn(transaction)
    end
    push_queue_transactions_update
    render nothing: true
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
    push_queue_transactions_update
    render nothing: true
  end

private
  def push_queue_transactions_update
    $redis.publish('queue_transactions.update', current_queue_transactions)
  end

  def load_queue_transaction
    @queue_transaction = QueueTransaction.find(params[:id])
  end

  def current_queue_transactions
    ActiveRecord::Base.connection.execute("
      select qt.id, u.email, qt.status,
      case qt.status
        when '#{QueueTransaction::RUNNING}' then round(extract(epoch from now() - qt.running_start_at)/60)
        when '#{QueueTransaction::WAITING}' then round(extract(epoch from now() - qt.waiting_start_at)/60)
        when '#{QueueTransaction::PENDING}' then round(extract(epoch from now() - qt.pending_start_at)/60)
      end as duration,
      case qt.status
        when '#{QueueTransaction::RUNNING}' then round(extract(epoch from now() - qt.pending_start_at)/60)
        when '#{QueueTransaction::PENDING}' then round(extract(epoch from now() - qt.pending_start_at)/60)
          else null end as blocking_duration,
      qt.user_id = #{current_user.id} as current_user
      from queue_transactions qt
      left join users u on qt.user_id = u.id

      where qt.is_complete is false
      order by qt.waiting_start_at"
    ).to_json
  end
end
