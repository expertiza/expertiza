class QuestionnaireNode < Node
  belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "node_object_id"
  belongs_to :node_object, class_name: "Questionnaire", foreign_key: "node_object_id"

  def self.table
    "questionnaires"
  end

  def self.get(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, search = nil)
    conditions = if show
                   if User.find(user_id).role.name != "Teaching Assistant"
                     'questionnaires.instructor_id = ?'
                   else
                     'questionnaires.instructor_id in (?)'
                                end
                 else
                   if User.find(user_id).role.name != "Teaching Assistant"
                     '(questionnaires.private = 0 or questionnaires.instructor_id = ?)'
                   else
                     '(questionnaires.private = 0 or questionnaires.instructor_id in (?))'
                                end
                 end

    values = if User.find(user_id).role.name != "Teaching Assistant"
               user_id
             else
               Ta.get_mapped_instructor_ids(user_id)
             end

    if parent_id
      name = TreeFolder.find(parent_id).name + "Questionnaire"
      name.gsub!(/[^\w]/, '')
      conditions += " and questionnaires.type = \"#{name}\""
    end

    name = search[:name].to_s.strip
    course_name = search[:course].to_s.strip
    assignment_name = search[:assignment].to_s.strip
    question_text = search[:question_text].to_s.strip

    if course_name.present?
      course = Course.find_by('name LIKE ?', "%#{course_name}%")
      instructor_id = course.instructor_id
      conditions += " and questionnaires.instructor_id = \"#{instructor_id}\""
    end

    if name.present?
      conditions += " and questionnaires.name LIKE \"%#{name}%\""
    end

    if question_text.present?
      matching_questionnaires = Question.where('txt LIKE ?', "%#{question_text}%")
      ids = matching_questionnaires.map(&:questionnaire_id)
      conditions += " and questionnaires.id in (#{ids.join(',')})"
    end

    matching_assignments = Assignment.where('name LIKE ?', "%#{assignment_name}%")
    matching_questionnaires = AssignmentQuestionnaire.where('assignment_id in (?)', matching_assignments.ids)
    questionnaire_ids = matching_questionnaires.map(&:questionnaire_id)
    conditions += " and questionnaires.id in (#{questionnaire_ids.join(',')})"

    sortvar = 'name' if sortvar.nil? or sortvar == 'directory_path'
    sortorder = 'ASC' if sortorder.nil?
    if Questionnaire.column_names.include? sortvar and %w[ASC DESC asc desc].include? sortorder
      self.includes(:questionnaire).where([conditions, values]).order("questionnaires.#{sortvar} #{sortorder}")
    end
  end

  def get_name
    Questionnaire.find_by(id: self.node_object_id).try(:name)
  end

  def get_private
    Questionnaire.find_by(id: self.node_object_id).try(:private)
  end

  def get_creation_date
    Questionnaire.find_by(id: self.node_object_id).try(:created_at)
  end

  def get_modified_date
    Questionnaire.find_by(id: self.node_object_id).try(:updated_at)
  end

  def is_leaf
    true
  end
end
