collection @queue_transactions

attributes :id
attributes :status
attributes :is_complete

attributes :blocking_duration

attributes :waiting_start_at
attributes :pending_start_at
attributes :running_start_at
attributes :force_release_at

attributes :finished_at
attributes :cancelled_at
attributes :created_at
attributes :updated_at

child(:user) do
  attributes :id
  attributes :email
  attributes :name
end