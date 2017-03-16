module LtiAssignmentUsersHelper
  def self.push_grade_to_lms_per_user lis_result_source_did, grade, lis_outcome_url, tenant
    # pre_process_tenant
    # lis_result_sourcedid = params["lis_result_sourcedid"];
    begin
      score = (grade.to_f)/100;
      xml = "<?xml version = \"1.0\" encoding = \"UTF-8\"?><imsx_POXEnvelopeRequest xmlns = \"http://www.imsglobal.org/services/ltiv1p1/xsd/imsoms_v1p0\"><imsx_POXHeader><imsx_POXRequestHeaderInfo><imsx_version>V1.0</imsx_version><imsx_messageIdentifier>58c756ebb18de</imsx_messageIdentifier></imsx_POXRequestHeaderInfo></imsx_POXHeader><imsx_POXBody><replaceResultRequest><resultRecord><sourcedGUID><sourcedId>"+lis_result_source_did+"</sourcedId></sourcedGUID><result><resultScore><language>en-US</language><textString>"+score.to_s+"</textString></resultScore></result></resultRecord></replaceResultRequest></imsx_POXBody></imsx_POXEnvelopeRequest>"
      signed_request = create_signed_request \
          lis_outcome_url,
          "POST",
          tenant.tenant_key,
          tenant.secret,
          {},
          xml,
          'application/xml'

      response = invoke_service(signed_request, Rails.application.config.wire_log, "Submit Result to ToolConsumer")

      puts response
    end
  rescue Exception => e
    @iresource.errors[:score] << "Score must be a real number from 0.0 to 1.0"
  end

  def self.post_grades_to_lms assignment_participants, grade
    assignment_participants.each do |assignment_participant|
      user_assignment = LtiAssignmentUser.find_by_participant_id assignment_participant.id;
      if user_assignment
        tenant = Tenant.find 31;
        puts "Hello"
        outcome_url = tenant.lis_outcome_service_url;
        puts outcome_url
        push_grade_to_lms_per_user user_assignment.lis_result_source_did, grade, outcome_url, tenant;
      end
    end
  end

  private_class_method :push_grade_to_lms_per_user

end
