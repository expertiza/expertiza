# frozen_string_literal: true

class AssignmentBadge < ApplicationRecord
  belongs_to :badge
  belongs_to :assignment
end
