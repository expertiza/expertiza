class TagPromptDeployment < ApplicationRecord
  belongs_to :tag_prompt
  belongs_to :assignment
  belongs_to :questionnaire
  has_many :answer_tags, dependent: :destroy

  require 'time'
  include ReviewMappingHelper

  def tag_prompt
    TagPrompt.find(tag_prompt_id)
  end

  def get_number_of_taggable_answers(user_id)
    team = Team.joins(:teams_users).where(team_users: { parent_id: assignment_id }, user_id: user_id)
    responses = Response.joins(:response_maps).where(response_maps: { reviewed_object_id: assignment.id, reviewee_id: team.id })
    questions = Question.where(questionnaire_id: questionnaire.id, type: question_type)

    unless responses.empty? || questions.empty?
      responses_ids = responses.map(&:id)
      questions_ids = questions.map(&:id)

      answers = Answer.where(question_id: questions_ids, response_id: responses_ids)

      answers = answers.where(conditions: "length(comments) < #{answer_length_threshold}") unless answer_length_threshold.nil?
      return answers.count
    end
    0
  end

  def assignment_tagging_progress
    teams = Team.where(parent_id: assignment_id)
    questions = Question.where(questionnaire_id: questionnaire.id, type: question_type)
    questions_ids = questions.map(&:id)
    user_answer_tagging = []
    unless teams.empty? || questions.empty?
      teams.each do |team|
        if assignment.varying_rubrics_by_round?
          responses = []
          1.upto(assignment.rounds_of_reviews).each do |round|
            responses += ReviewResponseMap.get_responses_for_team_round(team, round)
          end
        else
          responses = ResponseMap.assessments_for(team)
        end
        responses_ids = responses.map(&:id)
        answers = Answer.where(question_id: questions_ids, response_id: responses_ids)

        answers = answers.select { |answer| answer.comments.length > answer_length_threshold } unless answer_length_threshold.nil?
        answers_ids = answers.map(&:id)
        teams_users = TeamsUser.where(team_id: team.id)
        users = teams_users.map { |teams_user| User.find(teams_user.user_id) }

        users.each do |user|
          tags = AnswerTag.where(tag_prompt_deployment_id: id, user_id: user.id, answer_id: answers_ids)
          tagged_answers_ids = tags.map(&:answer_id)

          # E2082 Track_Time_Between_Successive_Tag_Assignments
          # Extract time where each tag is generated / modified
          tag_updated_times = tags.map(&:updated_at)
          # tag_updated_times.sort_by{|time_string| Time.parse(time_string)}.reverse
          tag_updated_times.sort.reverse
          number_of_updated_time = tag_updated_times.length
          tag_update_intervals = []
          1.upto(number_of_updated_time - 1).each do |i|
            tag_update_intervals.append(tag_updated_times[i] - tag_updated_times[i - 1])
          end

          percentage = answers.count.zero? ? '-' : format('%.1f', tags.count.to_f / answers.count * 100)
          not_tagged_answers = answers.reject { |answer| tagged_answers_ids.include?(answer.id) }

          # E2082 Adding tag_update_intervals as information that should be passed
          answer_tagging = VmUserAnswerTagging.new(user, percentage, tags.count, not_tagged_answers.count, answers.count, tag_update_intervals)
          user_answer_tagging.append(answer_tagging)
        end
      end
    end
    user_answer_tagging
  end

  # You can add groups of fields to the hashmap
  EXPORT_FIELDS = { team_score: ['Username', 'Name', '% of Tagged Answers', 'Tagged Answers', 'Not Tagged Answers', 'Intevals', 'Mean', 'Min', 'Variance', 'Standard', 'Deviation', 'Taggable Answers']}
  def self.export_fields(options)
    fields = []
    EXPORT_FIELDS.each do |key, value|
      value.each do |f|
        fields.push(f)
      end
    end
    fields
  end
  
  # This method is used for export contents of answerTag#view
  def self.export(csv, assignment_id, option)
    assignment = Assignment.find(assignment_id)
    tag_prompt_deployments = TagPromptDeployment.where(assignment_id: assignment.id)
    questionnaire_tagging_report = {}
    user_tagging_report = {}
    tag_prompt_deployments.each do |tag_dep|
      questionnaire_tagging_report[tag_dep] = tag_dep.assignment_tagging_progress
      questionnaire_tagging_report[tag_dep].each do |line|
        self.tagged_user_summary(user_tagging_report, line)
      end
    end
    sheets = self.export_data(questionnaire_tagging_report, option)
    sheets.each do |sheet, rows|
      csv << [sheet]
      rows.each do |row|
        csv << row
      end
    end
  end

  def self.tagged_user_summary(user_tagging_report, line)
    
    if user_tagging_report[line.user.name].nil?
      # E2082 Adding extra field of interval array into data structure
      user_tagging_report[line.user.name] = VmUserAnswerTagging.new(line.user, line.percentage, line.no_tagged, line.no_not_tagged, line.no_tagable, line.tag_update_intervals)
    else
      user_tagging_report[line.user.name].no_tagged += line.no_tagged
      user_tagging_report[line.user.name].no_not_tagged += line.no_not_tagged
      user_tagging_report[line.user.name].no_tagable += line.no_tagable
      user_tagging_report[line.user.name].percentage = self.calculate_formatted_percentage(user_tagging_report[line.user.name])
    end
  end

  def self.export_data(questionnaire_tagging_report, options)
    sheets = {}
    if questionnaire_tagging_report.nil? || questionnaire_tagging_report.count < 1
      sheets['sheet 1'] = ['No answer tags are found for this assignment']
    else
      questionnaire_tagging_report.each do |tag_dep, report_lines|
        sheetName = tag_dep.questionnaire.name + " (" + tag_dep.tag_prompt.prompt + ")"
        sheets[sheetName] = []
        report_lines.each do |report_line|
          row = []
          row.push(report_line.user.name)
          row.push(report_line.user.fullname)
          row.push(report_line.percentage.to_s)
          row.push(report_line.no_tagged.to_s)
          row.push(report_line.no_not_tagged.to_s)
          row.push(report_line.tag_update_intervals)
          key_chart_information = self.calculate_key_chart_information(report_line.tag_update_intervals)
          
          row.push(key_chart_information.nil? ? nil : key_chart_information[:mean])
          row.push(key_chart_information.nil? ? nil : key_chart_information[:min])
          row.push(key_chart_information.nil? ? nil : key_chart_information[:max])
          row.push(key_chart_information.nil? ? nil : key_chart_information[:variance])
          row.push(key_chart_information.nil? ? nil : key_chart_information[:stand_dev])
          
          row.push(report_line.no_tagable)
          sheets[sheetName].push(row)
        end
      end
      sheets
    end
  end

  def self.calculate_key_chart_information(intervals)
    # if someone did not do any tagging in 30 seconds, then ignore this interval
    threshold = 30
    interval_precision = 2 # Round to 2 Decimal Places
    intervals = intervals.select { |v| v < threshold }

    # Get Metrics once tagging intervals are available
    unless intervals.empty?
      metrics = {}
      metrics[:mean] = (intervals.reduce(:+) / intervals.size.to_f).round(interval_precision)
      metrics[:min] = intervals.min
      metrics[:max] = intervals.max
      sum = intervals.inject(0) { |accum, i| accum + (i - metrics[:mean])**2 }
      metrics[:variance] = (sum / intervals.size.to_f).round(interval_precision)
      metrics[:stand_dev] = Math.sqrt(metrics[:variance]).round(interval_precision)
      metrics
    end
    # if no Hash object is returned, the UI handles it accordingly
  end

  def self.calculate_formatted_percentage(user_tagging_report)
    number_tagged = user_tagging_report.no_tagged.to_f
    number_taggable = user_tagging_report.no_tagable
    formatted_percentage = format('%.1f', (number_tagged / number_taggable) * 100)
    user_tagging_report.no_tagable.zero? ? '-' : formatted_percentage
  end
end
