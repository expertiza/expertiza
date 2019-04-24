module AssignmentStatsHelper
  def avg_data(assignment_stats)
    [
      [76, 84,54, 92, 64],
      [64, 92, 78, 54]
    ]
  end
  def med_data(assignment_stats)
    [
      [3, 3.5, 2.5, 3.5, 3],
      [3, 3.5, 3, 2.5]
    ]
  end
  def criteria_names(assignment_stats)
    [
      [
        "Criterion 1",
        "Criterion 2",
        "Criterion 3",
        "Criterion 4",
        "Criterion 5"
      ],
      [
        "Criterion 1",
        "Criterion 2",
        "Criterion 3",
        "Criterion 4"
      ]
    ]
  end
  def round_names(assignment_stats)
    [
      "Round 1",
      "Round 2"
    ]
  end
end