class QuestionnaireNode < Node
  belongs_to :questionnaire, class_name: 'Questionnaire', foreign_key: 'node_object_id', inverse_of: false
  belongs_to :node_object, class_name: 'Questionnaire', foreign_key: 'node_object_id', inverse_of: false

  def self.table
    'questionnaires'
  end

  def self.get(_sortvar = 'name', _sortorder = 'desc', user_id = nil, show = nil, parent_id = nil, _search = nil)
    sortvar = 'name' if sortvar.nil? || (sortvar == 'directory_path')
    sortorder = 'ASC' if sortorder.nil?
    (includes(:questionnaire).where([get_questionnaire_query_conditions(show, user_id, parent_id), get_questionnaires_managed_by_user(user_id)]).order("questionnaires.#{sortvar} #{sortorder}") if Questionnaire.column_names.include?(sortvar) && %w[ASC DESC asc desc].include?(sortorder))
  end

  # get the query conditions for a questionnaire 
  def self.get_questionnaire_query_conditions(show = nil, user_id = nil, parent_id = nil)
    current_user = User.find_by(id: user_id)
    conditions = if show
                    if current_user.role.name != 'Teaching Assistant'
                      'questionnaires.instructor_id = ?'
                    else
                      'questionnaires.instructor_id in (?)'
                    end
                elsif current_user.role.name != 'Teaching Assistant'
                    '(questionnaires.private = 0 or questionnaires.instructor_id = ?)'
                else
                    '(questionnaires.private = 0 or questionnaires.instructor_id in (?))'
                end
    if parent_id
      name = TreeFolder.find(parent_id).name + 'Questionnaire'
      name.gsub!(/[^\w]/, '')
      conditions += " and questionnaires.type = \"#{name}\""
    end
    conditions
  end

  # get the questionnaire managed by the user
  def self.get_questionnaires_managed_by_user(user_id = nil)
    current_user = User.find(user_id)
    values = if current_user.role.name == 'Teaching Assistant'
              Ta.get_mapped_instructor_ids(user_id)
            else
              user_id
            end
    values
  end

  
  def get_name
    Questionnaire.find_by(id: node_object_id).try(:name)
  end

  # this method return instructor id associated with a questionnaire
  # returns int
  def get_instructor_id
    Questionnaire.find_by(id: node_object_id).try(:instructor_id)
  end

  # Gets if the questionnaire is private or not 
  # Return tinyint datatype :- 1 or 0
  def get_private
    Questionnaire.find_by(id: node_object_id).try(:private)
  end

  # Gets the creation date of the questionnaire
  # Returns datetime datatype
  def get_creation_date
    Questionnaire.find_by(id: node_object_id).try(:created_at)
  end

  # Gets the date whe the questionnaire was modified
  # Returns datetime datatype
  def get_modified_date
    Questionnaire.find_by(id: node_object_id).try(:updated_at)
  end

  # Indicates that this object is always a leaf
  def is_leaf
    true
  end
end
