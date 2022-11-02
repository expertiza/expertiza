# frozen_string_literal: true

class DelayedJob < Delayed::Job
  has_paper_trail
end
