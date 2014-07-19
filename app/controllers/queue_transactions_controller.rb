class QueueTransactionsController < ApplicationController
  include ActionController::Live

  Mime::Type.register "text/event-stream", :stream

  # def index
  #   respond_to do |format|
  #     format.html
  #     format.stream {
  #       response.headers['Content-Type'] = 'text/event-stream'
  #       data = {'email' => 'robert@asd', 'status' => 'Running forever', 'blocking' => '12:12:12'}.to_json
  #
  #       begin
  #         loop do
  #           # Share.uncached do
  #             response.stream.write "data: #{generate_new_values.to_json}\n\n"
  #           # end
  #           sleep 1.second
  #         end
  #       rescue IOError # Raised when browser interrupts the connection
  #       ensure
  #         response.stream.close # Prevents stream from being open forever
  #       end
  #     }
  #   end
  # end

  def index
    QueueTransaction.where(:is_complete => false).order("waiting_start_at asc").load
  end

  def le_update
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Streamer::SSE.new(response.stream)
    redis = Redis.new
    redis.subscribe('messages.create') do |on|
      on.message do |event, data|
        sse.write(data, event: 'messages.create')
      end
    end
    render nothing: true
  rescue IOError
    # Client disconnected
  ensure
    redis.quit
    sse.close
  end
  # end
  #
  # def generate_new_values
  #   transactions = QueueTransaction.where(:is_complete => false).order("waiting_start_at asc").load
  #
  #   transactions.map do |transaction|
  #     {email: transaction.user.email, status: transaction.status, blocking: Time.now}
  #   end
  # end

  def create
    if QueueTransaction.where(:is_complete => false).count == 0
      now = Time.now
      QueueTransaction.create\
        :user_id => current_user.id,
        :waiting_start_at => now,
        :pending_start_at => now,
        :running_start_at => now,
        :is_complete => false
    else
      QueueTransaction.create :user_id => current_user.id, :waiting_start_at => Time.now, :is_complete => false
    end

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    end

    redirect_to root_path
  end

  def cancel
    load_queue_transaction
    @queue_transaction.update_attributes :cancelled_at => Time.now, :is_complete => true

    first_in_queue = QueueTransaction.get_first_in_queue
    next_in_queue = QueueTransaction.get_next_in_queue(@queue_transaction)
    if first_in_queue == next_in_queue
      next_in_queue.update_attributes :pending_start_at => Time.now
      UserMailer.notify_user_of_turn(next_in_queue)
    end

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    end

    redirect_to root_path
  end

  def run
    load_queue_transaction

    @queue_transaction.update_attributes :running_start_at => Time.now

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    else
      Gorgon.run(current_user.id)
    end

    redirect_to root_path
  end

  def finish
    load_queue_transaction
    @queue_transaction.update_attributes :finished_at => Time.now, :is_complete => true
    transaction = QueueTransaction.get_first_in_queue
    if transaction
      transaction.update_attributes :pending_start_at => Time.now
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

    render :json => {:next_in_line => next_in_line}
  end

  def force_release
    load_queue_transaction
    @queue_transaction.update_attributes force_release_at: Time.now, is_complete: true#, finished_at: Time.now
    UserMailer.notify_release(@queue_transaction)
    transaction = QueueTransaction.get_first_in_queue
    if transaction
      transaction.update_attributes pending_start_at: Time.now
      UserMailer.notify_user_of_turn(transaction)
    end

    redirect_to root_path
  end

private
  def load_queue_transaction
    @queue_transaction = QueueTransaction.find(params[:id])
  end

  def queue_transaction_params
    params.require(:queue_transaction).permit(:waiting_start_at, :pending_start_at, :running_start_at, :user_id, :finished_at, :cancelled_at, :is_complete, :force_release_at)
  end
end
