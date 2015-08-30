require 'csv'

module ImportFileHelper

  def self.define_attributes(row,row_header)
    attributes = {}
    attributes["role_id"] = Role.student.id
    index=0
    #default will be blank
    attributes["name"]=nil
    attributes["fullname"]=nil
    attributes["email"]=nil
    attributes["password"] = nil

    if (row_header==nil)
      attributes["name"] = row[0].strip
      attributes["fullname"] = row[1]
      attributes["email"] = row[2].strip

      password=row[3]
      if (password[0]=="[")
        password=password[1..password.length]
        password=password[0..password.length-2]
      end

      if (password!="")
        attributes["password"] = password
      end
    else
      row_header.each do |item|
        attributes[item.strip]=row[index].strip
        index=index+1
      end
    end
    attributes["password_confirmation"] = attributes["password"]
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end
  def self.create_new_user(attributes, session)
    user = User.new(attributes)
    user.parent_id = (session[:user]).id
    user.save!
    user
  end
end

