class QueueTransactionsController < ApplicationController

  def index
    @queue = QueueTransaction.where(:is_complete => false).order("waiting_start_at asc").all
  end

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
    transaction = QueueTransaction.get_next_in_line
    if transaction
      transaction.update_attributes :pending_start_at => Time.now
      UserMailer.notify_next_in_line
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
    transaction = QueueTransaction.get_next_in_line
    if transaction
      transaction.update_attributes :pending_start_at => Time.now
    end
    UserMailer.notify_next_in_line

    if current_user.errors.any?
      flash[:error] = current_user.errors.full_messages
    else
      Gorgon.finish
    end

    redirect_to root_path
  end

private
  def load_queue_transaction
    @queue_transaction = QueueTransaction.find(params[:id])
  end
end