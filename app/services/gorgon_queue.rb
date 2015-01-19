module GorgonQueue
  extend GorgonQueue::Transitions
  extend GorgonQueue::Queries
  extend GorgonQueue::Metrics

  class TransitionException < RuntimeError; end
end