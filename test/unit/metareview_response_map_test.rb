require File.dirname(__FILE__) + '/../test_helper'

class MetareviewResponseMapTest < ActiveSupport::TestCase
  fixtures :response_maps, :questionnaires , :assignments, :responses , :response_maps

  test "method_get_all_versions" do
    p = MetareviewResponseMap.new
    p.review_mapping = response_maps(:response_maps0)
    puts p.get_all_versions
    assert p.valid?
  end

  test "method_contributor" do
    p = MetareviewResponseMap.new
    p.review_mapping = response_maps(:response_maps0)
    p.contributor
    assert p.valid?
  end

  test "method_questionnaire" do
    p = MetareviewResponseMap.new
    p.review_mapping = response_maps(:response_maps0)
    #p.assignment.questionnaires = questionnaires(:questionnaire0)
    p.questionnaire
  end

  test "method_get_title" do
    p = MetareviewResponseMap.new
    assert_equal p.get_title, "Metareview"
  end

  test "method_assignment" do
    p = MetareviewResponseMap.new
    p.review_mapping = response_maps(:response_maps0)
    assert p.assignment.valid?
  end

  test "method_get_export" do
    p = assignments(:assignment7)
    fields_1 = ["contributor"]
    MetareviewResponseMap.export([1,2],p,1)
    fields_2 = MetareviewResponseMap.get_export_fields(1)
    assert_equal fields_1[0], fields_2[0]
  end

  test "method_get_export_fields" do
    fields_1 = ["contributor","reviewed by","metareviewed by"]
    fields_2 = MetareviewResponseMap.get_export_fields(1)
    assert_equal fields_2[0], fields_1[0]
    assert_equal fields_2[1], fields_1[1]
    assert_equal fields_2[2], fields_1[2]
  end

  test "method_import_when_argument_less_three" do
    assert_raise (ArgumentError){MetareviewResponseMap.import(['student2','student2'], 2, "827400667")}
  end

  test "method_import" do
  assert_equal nil, MetareviewResponseMap.import(['student2','student1','student3'], 2, "20698453")
  end
end