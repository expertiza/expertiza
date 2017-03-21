require 'rails_helper'
require 'yaml'
require 'json'

expected_student_cache = YAML.load_file("#{Rails.root}/config/role_student.yml")[Rails.env]
expected_instructor_cache = YAML.load_file("#{Rails.root}/config/role_instructor.yml")[Rails.env]
expected_admin_cache = YAML.load_file("#{Rails.root}/config/role_admin.yml")[Rails.env]

describe Role do
  before :all do
    @student_role = build(:role_of_student, id: 1, name: "Student", description: '', parent_id: nil, default_page_id: nil)
    @instructor_role = build(:role_of_instructor, id: 2, name: "Instructor", description: '', parent_id: nil, default_page_id: nil)
    @admin_role = build(:role_of_administrator, id: 3, name: "Administrator", description: '', parent_id: nil, default_page_id: nil)
    @invalid_role = build(:role_of_student, id: 1, name: nil, description: "", parent_id: nil, default_page_id: nil)
  end

  it "cache value of student role matches with student YAML" do
    expect(@student_role.cache.to_json).to eq(expected_student_cache.to_json)
  end

  it "cache value of instructor role matches with instructor YAML" do
    expect(@instructor_role.cache.to_json).to eq(expected_instructor_cache.to_json)
  end

  it "cache value of admin role matches with admin YAML" do
    expect(@admin_role.cache.to_json).to eq(expected_admin_cache.to_json)
  end

  it "cache value of student role does not match with student YAML" do
    expect(@student_role.cache.to_json).not_to eq(expected_admin_cache.to_json)
  end

  it "cache value of instructor role does not match with instructor YAML" do
    expect(@instructor_role.cache.to_json).not_to eq(expected_student_cache.to_json)
  end

  it "cache value of admin role does not match with admin YAML" do
    expect(@admin_role.cache.to_json).not_to eq(expected_instructor_cache.to_json)
  end
end