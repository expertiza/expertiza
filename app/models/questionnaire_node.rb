class QuestionnaireNode < Node
  belongs_to :questionnaire, :class_name => "Questionnaire", :foreign_key => "node_object_id"
  belongs_to :node_object, :class_name => "Questionnaire"

  def self.table
    "questionnaires"
  end

  def self.get(sortvar = nil,sortorder = nil, user_id = nil,show = nil,parent_id = nil,search=nil)
    if show
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = 'questionnaires.instructor_id = ?'
      else
        conditions = 'questionnaires.instructor_id in (?)'
      end
    else
      if User.find(user_id).role.name != "Teaching Assistant"
        conditions = '(questionnaires.private = 0 or questionnaires.instructor_id = ?)'
      else
        conditions = '(questionnaires.private = 0 or questionnaires.instructor_id in (?))'
      end
    end

    if User.find(user_id).role.name != "Teaching Assistant"
      values = user_id
    else
      values = Ta.get_mapped_instructor_ids(user_id)
    end

    if parent_id
      name = TreeFolder.find(parent_id).name+"Questionnaire"
      name.gsub!(/[^\w]/,'')
      conditions +=  " and questionnaires.type = \"#{name}\""
    end

    if sortvar.nil? or sortvar == 'directory_path'
      sortvar = 'name'
    end
    if sortorder.nil?
      sortorder = 'ASC'
    end

    if search
      splitsearch = search.split("+")
      if(splitsearch[0] == "filter" && splitsearch.length > 1)
        splitsearch.delete_at(0)
        conditions += " and questionnaires.id in "
        if splitsearch.length == 1
          conditions += splitsearch[0]
        else
          conditions += "("+splitsearch[0]
                          i=1
                          while i < splitsearch.length do
                            conditions += ',' + splitsearch[i]
                            i = i+1
                          end
                          conditions += ')'
        end
        all().includes(:questionnaire).conditions([conditions,values]).order("questionnaires.#{sortvar} #{sortorder}")
      else
        conditions += " and questionnaires.name LIKE ?"
        search = "%"+search+"%"
        self.includes(:questionnaire).where([conditions,values,search]).order("questionnaires.#{sortvar} #{sortorder}")
        end

    else
      self.includes(:questionnaire).where([conditions,values]).order("questionnaires.#{sortvar} #{sortorder}")
    end
  end

  def get_name
    Questionnaire.find(self.node_object_id).name
  end

  def get_creation_date
    Questionnaire.find(self.node_object_id).created_at
  end

  # Gets the updated_at from the associated Questionnaire
  def get_modified_date
    Questionnaire.find(self.node_object_id).updated_at
  end

  def is_leaf
    true
  end
end
