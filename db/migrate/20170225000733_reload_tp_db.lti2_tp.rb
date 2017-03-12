# This migration comes from lti2_tp (originally 20151111000001)
class ReloadTpDb < ActiveRecord::Migration
  def up
    create_table "lti2_tp_registrations", force: true do |t|
      t.integer  "tenant_id"
      t.string   "tenant_name"
      t.string   "tenant_basename"
      t.string   "user_id"
      t.string   "reg_key"
      t.text     "reg_password"
      t.string   "tool_proxy_guid"
      t.text     "final_secret"
      t.string   "tc_profile_url"
      t.string   "launch_presentation_return_url"
      t.string   "status"
      t.string   "message_type"
      t.string   "lti_version",                    limit: 32
      t.string   "end_registration_id"
      t.integer  "tool_id"
      t.text     "tool_consumer_profile_json"
      t.text     "tool_profile_json"
      t.text     "tool_proxy_json"
      t.text     "proposed_tool_proxy_json"
      t.text     "tool_proxy_response"
      t.datetime "created_at",                                null: false
      t.datetime "updated_at",                                null: false
    end

    create_table "lti2_tp_registries", force: true do |t|
      t.string   "name"
      t.text     "content"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "lti2_tp_tools", force: true do |t|
      t.string   "tool_name"
      t.text     "tool_profile_template"
      t.datetime "created_at",            null: false
      t.datetime "updated_at",            null: false
    end

    create_table "lti_registration_wips", force: true do |t|
      t.string   "tenant_name"
      t.integer  "registration_id"
      t.string   "lti_version"
      t.text     "tool_consumer_profile"
      t.text     "tool_profile"
      t.string   "registration_return_url"
      t.string   "message_type"
      t.text     "tool_proxy"
      t.string   "state"
      t.integer  "result_status"
      t.string   "result_message"
      t.string   "support_email"
      t.string   "product_name"
      t.datetime "created_at",              null: false
      t.datetime "updated_at",              null: false
    end
  end

  def down
    drop_table :lti2_tp_registrations
    drop_table :lti2_tp_registries
    drop_table :lti2_tp_tools
  end
end
