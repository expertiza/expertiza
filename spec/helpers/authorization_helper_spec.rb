describe AuthorizationHelper do
  # Set up some dummy users
  # Inspired by spec/controllers/users_controller_spec.rb
  # Makes use of spec/factories/factories.rb
  # Use create instead of build so that these users get IDs
  # https://stackoverflow.com/questions/41149787/how-do-i-create-an-user-id-for-a-factorygirl-build
  let(:student) { create(:student) }
  let(:teaching_assistant) { create(:teaching_assistant) }
  let(:instructor) { create(:instructor) }
  let(:admin) { create(:admin) }
  let(:superadmin) { create(:superadmin) }
  let(:assignment_team) { create(:assignment_team) }

  # The global before(:each) in spec/spec_helper.rb establishes roles before each test runs

  # TESTS

  # HAS PRIVILEGES (Super Admin --> Admin --> Instructor --> TA --> Student)

  describe '.current_user_has_super_admin_privileges?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_super_admin_privileges?).to be true
    end
  end

  describe '.current_user_has_admin_privileges?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns false for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns false for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_admin_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_admin_privileges?).to be true
    end
  end

  describe '.current_user_has_instructor_privileges?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      expect(current_user_has_instructor_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_instructor_privileges?).to be false
    end

    it 'returns false for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_instructor_privileges?).to be false
    end

    it 'returns true for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_instructor_privileges?).to be true
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_instructor_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_instructor_privileges?).to be true
    end
  end

  describe '.current_user_has_ta_privileges?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      expect(current_user_has_ta_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_ta_privileges?).to be false
    end

    it 'returns true for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_ta_privileges?).to be true
    end
  end

  describe '.current_user_has_student_privileges?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      expect(current_user_has_student_privileges?).to be false
    end

    it 'returns true for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_student_privileges?).to be true
    end
  end

  describe '.current_user_teaching_staff_of_assignment?' do
    # # Rather than specifying IDs explicitly for instructor, TA, course, etc.
    # # Use factory create method to auto generate IDs.
    # # In this way we have less risk of making a mistake (e.g. duplication) in the ID numbers.
    #
    # it 'returns false if the user is not logged in' do
    #   instructor1 = create(:instructor)
    #   instructor2 = create(:instructor)
    #   course = create(:course, instructor_id: instructor2.id)
    #   assignment = create(:assignment, course_id: course.id)
    #   session[:user] = nil
    #   expect(current_user_teaching_staff_of_assignment?(assignment.id)).to be false
    # end
    #
    # it 'returns true if the instructor is assigned to the course of the assignment' do
    #   # To be on the safe side (avoid passing this test when there might be some problem)
    #   # Create 2 instructors and associate the 2nd one with the assignment
    #   # See comments in other tests of this method
    #   # Briefly: There is some implicit automatic association to 1st instructor via factory
    #
    #   instructor1 = create(:instructor)
    #   instructor2 = create(:instructor)
    #   course = create(:course, instructor_id: instructor2.id)
    #   assignment = create(:assignment, course_id: course.id)
    #   stub_current_user(instructor2, instructor2.role.name, instructor2.role)
    #   expect(current_user_teaching_staff_of_assignment?(assignment.id)).to be true
    # end
    #
    # it 'returns false if the instructor is not assigned to the course of the assignment' do
    #   # This test requires some extra care
    #   # The assignment factory will associate the created assignment with the first course
    #   # (or will create a course if needed)
    #   # The assignment factory in will ALSO associate the assignment with the first instructor
    #   # (or will create an instructor if needed)
    #   # Therefore, with no extra care, the assignment will end up associated with the first instructor
    #   # Therefore, we must take care that we specify both the course and the instructor for the assignment
    #
    #   instructor1 = create(:instructor)
    #   instructor2 = create(:instructor)
    #   course = create(:course, instructor_id: instructor2.id)
    #   assignment = create(:assignment, course_id: course.id, instructor_id: instructor2.id)
    #   stub_current_user(instructor1, instructor1.role.name, instructor1.role)
    #   expect(current_user_teaching_staff_of_assignment?(assignment.id)).to be false
    # end
    #
    # it 'returns true if the instructor is associated with the assignment' do
    #   # To be on the safe side (avoid passing this test when there might be some problem)
    #   # Create 2 instructors and associate the 2nd one with the assignment
    #   # See comments in other tests of this method
    #   # Briefly: There is some implicit automatic association to 1st instructor via factory
    #
    #   instructor1 = create(:instructor)
    #   instructor2 = create(:instructor)
    #   assignment = create(:assignment, instructor_id: instructor2.id)
    #   stub_current_user(instructor2, instructor2.role.name, instructor2.role)
    #   expect(current_user_teaching_staff_of_assignment?(assignment.id)).to be true
    # end
    #
    # it 'returns false if the instructor is not associated with the assignment' do
    #   # This test requires some extra care
    #   # The assignment factory will associate the created assignment with the first course
    #   # (or will create a course if needed)
    #   # The course factory in turn will associate the course with the first instructor
    #   # (or will create an instructor if needed)
    #   # Therefore, with no extra care, the assignment will end up associated indirectly with the first instructor
    #   # Therefore, we must take care that the current user we stub here is NOT the first instructor
    #
    #   instructor1 = create(:instructor)
    #   instructor2 = create(:instructor)
    #   assignment = create(:assignment, instructor_id: instructor1.id)
    #   stub_current_user(instructor2, instructor2.role.name, instructor2.role)
    #   expect(current_user_teaching_staff_of_assignment?(assignment.id)).to be false
    # end

    it 'returns true if the teaching assistant is associated with the course of the assignment' do
      teaching_assistant1 = create(:teaching_assistant)
      course = create(:course)
      assignment = create(:assignment)
      TaMapping.create(ta_id: teaching_assistant1.id, course_id: course.id)
      stub_current_user(teaching_assistant1, teaching_assistant1.role.name, teaching_assistant1.role)
      expect(current_user_teaching_staff_of_assignment?(assignment.id)).to be true
    end

    it 'returns false if the teaching assistant is not associated with the course of the assignment' do
      instructor1 = create(:instructor)
      teaching_assistant1 = create(:teaching_assistant)
      assignment = create(:assignment, instructor_id: instructor1.id)
      stub_current_user(teaching_assistant1, teaching_assistant1.role.name, teaching_assistant1.role)
      expect(current_user_teaching_staff_of_assignment?(assignment.id)).to be false
    end
  end

  # OTHER HELPER METHODS

  describe '.current_user_is_assignment_participant?' do
    # Makes use of existing :assignment_team, :participant, and :assignment factories

    it 'returns false if there is no current user' do
      session[:user] = nil
      participant = create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(participant.assignment.id)).to be false
    end

    it 'returns false if an erroneous id is passed in' do
      stub_current_user(student, student.role.name, student.role)
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(-1)).to be false
    end

    it 'returns false if the current user does not participate in the assignment' do
      stub_current_user(student, student.role.name, student.role)
      participant = create(:participant, user: instructor)
      expect(current_user_is_assignment_participant?(participant.assignment.id)).to be false
    end

    it 'returns true if current user is a student and participates in assignment' do
      stub_current_user(student, student.role.name, student.role)
      participant = create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(participant.assignment.id)).to be true
    end

    it 'returns true if current user is a TA and participates in assignment' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      participant = create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(participant.assignment.id)).to be true
    end

    it 'returns true if current user is an instructor and participates in assignment' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      participant = create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(participant.assignment.id)).to be true
    end

    it 'returns true if current user is an admin and participates in assignment' do
      stub_current_user(admin, admin.role.name, admin.role)
      participant = create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(participant.assignment.id)).to be true
    end

    it 'returns true if current user is a super-admin and participates in assignment' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      participant = create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(participant.assignment.id)).to be true
    end
  end

  describe '.current_user_created_bookmark_id?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      create(:bookmark, user: student)
      expect(current_user_created_bookmark_id?(Bookmark.first.id)).to be false
    end

    it 'returns false if there is no bookmark' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_created_bookmark_id?(12_345_678)).to be false
    end

    it 'returns false if the current user did not create the bookmark' do
      stub_current_user(student, student.role.name, student.role)
      create(:bookmark, user: teaching_assistant)
      expect(current_user_created_bookmark_id?(Bookmark.first.id)).to be false
    end

    it 'returns true if the current user did create the bookmark' do
      stub_current_user(student, student.role.name, student.role)
      create(:bookmark, user: student)
      expect(current_user_created_bookmark_id?(Bookmark.first.id)).to be true
    end
  end

  describe '.current_user_is_a?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      expect(current_user_is_a?('Student')).to be false
    end

    it 'returns false if there is a current user no role' do
      random_user = build(:teaching_assistant, role_id: nil)
      session[:user] = random_user
      expect(current_user_is_a?('Teaching Assistant')).to be false
    end

    it 'returns false if an erroneous role is passed in' do
      expect(current_user_is_a?('Random Role')).to be false
    end

    it 'returns true if current user and parameter are both Student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_is_a?('Student')).to be true
    end

    it 'returns true if current user and parameter are both Teaching Assistant' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_is_a?('Teaching Assistant')).to be true
    end

    it 'returns true if current user and parameter are both Instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_is_a?('Instructor')).to be true
    end

    it 'returns true if current user and parameter are both Administrator' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_is_a?('Administrator')).to be true
    end

    it 'returns true if current user and parameter are both Super-Administrator' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_is_a?('Super-Administrator')).to be true
    end
  end

  describe '.current_user_has_id?' do
    it 'returns false if there is no current user' do
      session[:user] = nil
      expect(current_user_has_id?(-1)).to be false
    end

    it 'returns false if current user exists but an erroneous id is passed in' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_id?(-1)).to be false
    end

    it 'returns false if passed in id does not match current user id' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_id?(student.id + 1)).to be false
    end

    it 'returns true if passed in id matches the current user id' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_id?(instructor.id)).to be true
    end

    it 'returns true if passed in id is the string version of current user id' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_id?(instructor.id.to_s)).to be true
    end
  end

  describe '.given_user_can_submit?' do
    it 'returns false if there is no given user' do
      expect(given_user_can_submit?(nil)).to be false
    end

    it 'returns false if the given user cannot be found' do
      expect(given_user_can_submit?(-1)).to be false
    end

    it 'returns false if the given user cannot submit' do
      participant = create(:participant, can_submit: 0)
      expect(given_user_can_submit?(participant.id)).to be false
    end

    it 'returns true if the given user can submit' do
      participant = create(:participant, can_submit: 1)
      expect(given_user_can_submit?(participant.id)).to be true
    end
  end

  describe '.given_user_can_review?' do
    it 'returns false if there is no given user' do
      expect(given_user_can_review?(nil)).to be false
    end

    it 'returns false if the given user cannot be found' do
      expect(given_user_can_review?(-1)).to be false
    end

    it 'returns false if the given user cannot review' do
      participant = create(:participant, can_review: 0)
      expect(given_user_can_review?(participant.id)).to be false
    end

    it 'returns true if the given user can review' do
      participant = create(:participant, can_review: 1)
      expect(given_user_can_review?(participant.id)).to be true
    end
  end

  describe '.given_user_can_take_quiz?' do
    it 'returns false if there is no given user' do
      expect(given_user_can_take_quiz?(nil)).to be false
    end

    it 'returns false if the given user cannot be found' do
      expect(given_user_can_take_quiz?(-1)).to be false
    end

    it 'returns false if the given user cannot read' do
      participant = create(:participant, can_take_quiz: 0)
      expect(given_user_can_take_quiz?(participant.id)).to be false
    end

    it 'returns true if the given user can read' do
      participant = create(:participant, can_take_quiz: 1)
      expect(given_user_can_take_quiz?(participant.id)).to be true
    end
  end

  describe '.given_user_can_read?' do
    it 'returns false if there is no given user' do
      expect(given_user_can_read?(nil)).to be false
    end

    it 'returns false if the given user cannot be found' do
      expect(given_user_can_read?(-1)).to be false
    end

    it 'returns false if the given user cannot read' do
      participant = create(:participant, can_take_quiz: 0)
      expect(given_user_can_read?(participant.id)).to be false
    end

    it 'returns true if the given user can read' do
      participant = create(:participant, can_take_quiz: 1)
      expect(given_user_can_read?(participant.id)).to be true
    end
  end

  describe '.response_edit_allowed?' do
    it 'returns false if current user is not logged in' do
      map = create(:review_response_map)
      session[:user] = nil
      expect(response_edit_allowed?(map, 1)).to be false
    end

    it 'returns false if map is not of type ReviewResponseMap and logged in user is not the reviewer' do
      map = create(:meta_review_response_map)
      expect(response_edit_allowed?(map, 80)).to be false
    end

    it 'returns true if map is not of type ReviewResponseMap and logged in user is the reviewer' do
      stub_current_user(instructor, instructor.role.name, instructor.role)

      reviewer = create(:participant, user_id: session[:user].id)
      map = create(:meta_review_response_map, reviewer: reviewer)
      expect(response_edit_allowed?(map, map.reviewer.user_id)).to be true
    end

    it 'returns true if map is of type ReviewResponseMap and logged in user is the reviewer' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      reviewer = create(:participant, user_id: session[:user].id)
      map = create(:review_response_map, reviewer: reviewer)
      expect(response_edit_allowed?(map, map.reviewer.user_id)).to be true
    end

    it 'returns true if map is of type ReviewResponseMap and current user is on the reviewee team' do
      stub_current_user(student, student.role.name, student.role)
      reviewer = create(:participant)
      team = create(:assignment_team)
      TeamNode.create(node_object_id: team.id)
      team.add_member(session[:user])
      map = create(:review_response_map, reviewer: reviewer, reviewee_id: team.id)
      expect(response_edit_allowed?(map, map.reviewer.user_id)).to be true
    end

    it 'returns true if map is of type ReviewResponseMap and user is an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      map = create(:review_response_map)
      expect(response_edit_allowed?(map, map.reviewer.user_id)).to be true
    end

    it 'returns true if map is of type ReviewResponseMap and user is an instructor associated with the assignment' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      assignment = create(:assignment, instructor_id: session[:user].id)
      reviewer = create(:participant, assignment: assignment)
      map = create(:review_response_map, reviewer: reviewer)
      expect(response_edit_allowed?(map, map.reviewer.user_id)).to be true
    end

    it 'returns true if map is of type ReviewResponseMap and user is a Teaching Assistant and a mapping exists between the user and the course of the assignment' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      course = create(:course)
      TaMapping.create(ta_id: session[:user].id, course_id: course.id)
      reviewer = create(:participant)
      map = create(:review_response_map, reviewer: reviewer)
      expect(response_edit_allowed?(map, map.reviewer.user_id)).to be true
    end
  end

  describe '.current_user_ancestor_of?' do
    it 'returns false if there is no logged in user' do
      session[:user] = nil
      expect(current_user_ancestor_of?(instructor)).to be false
    end

    it 'returns false if the user argument is null' do
      expect(current_user_ancestor_of?(nil)) .to be false
    end

    it 'returns false if there is a currently logged in user, but the target user has no parent' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      allow(student).to receive(:parent).and_return(nil)
      expect(current_user_ancestor_of?(student)).to be false
    end

    it 'returns false if the current user is not an ancestor of the target user' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      parent = create(:instructor, parent_id: nil)
      allow(student).to receive(:parent).and_return(parent)
      expect(current_user_ancestor_of?(student)).to be false
    end

    it 'returns true if the current user is a parent of the target user' do
      ta = create(:teaching_assistant, parent_id: nil)
      stub_current_user(ta, ta.role.name, ta.role)
      allow(student).to receive(:parent).and_return(ta)
      expect(current_user_ancestor_of?(student)).to be true
    end

    it 'returns true if the current user is a grandparent of the target user' do
      instructor1 = create(:instructor, parent_id: nil)
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      allow(teaching_assistant).to receive(:parent).and_return(instructor1)
      allow(student).to receive(:parent).and_return(teaching_assistant)
      expect(current_user_ancestor_of?(student)).to be true
    end

    it 'returns true if the current user is a great grandparent of the target user' do
      admin1 = create(:admin, parent_id: nil)
      stub_current_user(admin1, admin1.role.name, admin1.role)
      allow(instructor).to receive(:parent).and_return(admin1)
      allow(teaching_assistant).to receive(:parent).and_return(instructor)
      allow(student).to receive(:parent).and_return(teaching_assistant)
      expect(current_user_ancestor_of?(student)).to be true
    end
  end

  describe '.current_user_instructs_assignment?' do
    it 'returns false if there is no logged in user' do
      assignment = create(:assignment)
      session[:user] = nil
      expect(current_user_instructs_assignment?(assignment)).to be false
    end

    it 'returns false if the assignment argument is nil' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_instructs_assignment?(nil)) .to be false
    end

    it 'returns false if the assignment has some other instructor' do
      instructor1 = create(:instructor, username: 'test_instructor_1')
      instructor2 = create(:instructor, username: 'test_instructor_2')
      assignment = create(:assignment, instructor_id: instructor1.id)
      stub_current_user(instructor2, instructor2.role.name, instructor2.role)
      expect(current_user_instructs_assignment?(assignment)).to be false
    end

    it 'returns true if the assignment is instructed by the current user' do
      assignment = create(:assignment, instructor_id: instructor.id)
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_instructs_assignment?(assignment)).to be true
    end

    it 'returns true if the course associated with the assignment is instructed by the current user' do
      instructor1 = create(:instructor, username: 'test_instructor_1')
      instructor2 = create(:instructor, username: 'test_instructor_2')
      course = create(:course, instructor_id: instructor1.id)
      assignment = create(:assignment, instructor_id: instructor2.id, course_id: course.id)
      stub_current_user(instructor1, instructor1.role.name, instructor1.role)
      expect(current_user_instructs_assignment?(assignment)).to be true
    end
  end

  describe '.current_user_has_ta_mapping_for_assignment?' do
    it 'returns false if there is no logged in user' do
      assignment = create(:assignment)
      session[:user] = nil
      expect(current_user_has_ta_mapping_for_assignment?(assignment)).to be false
    end

    it 'returns false if the assignment argument is nil' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_ta_mapping_for_assignment?(nil)) .to be false
    end

    it 'returns false if the current user and the given assignment are NOT associated by a TA mapping' do
      ta1 = create(:teaching_assistant, username: 'test_ta_1')
      ta2 = create(:teaching_assistant, username: 'test_ta_2')
      course = create(:course)
      assignment = create(:assignment, course_id: course.id)
      TaMapping.create(ta_id: ta1.id, course_id: course.id)
      stub_current_user(ta2, ta2.role.name, ta2.role)
      expect(current_user_has_ta_mapping_for_assignment?(assignment)).to be false
    end

    it 'returns true if the current user and the given assignment are associated by a TA mapping' do
      course = create(:course)
      assignment = create(:assignment, course_id: course.id)
      TaMapping.create(ta_id: teaching_assistant.id, course_id: course.id)
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_ta_mapping_for_assignment?(assignment)).to be true
    end
  end

  describe '.find_assignment_from_response_id' do
    # Makes use of existing :response, :review_response_map, and :meta_review_response_map factories

    it 'returns the assignment if one is found without recursion' do
      response = create(:response)
      expect(find_assignment_from_response_id(response.id)).to eq(response.response_map.assignment)
    end

    it 'returns the assignment if one is found with 1 level of recursion' do
      metareview_response = create(:meta_review_response_map)
      response = create(:response, response_map: metareview_response)
      expect(find_assignment_from_response_id(response.id)).to eq(response.response_map.review_mapping.assignment)
    end

    it 'returns the assignment if one is found with multiple levels of recursion' do
      review_response = create(:review_response_map)
      metareview_response1 = create(:meta_review_response_map, review_mapping: review_response)
      metareview_response2 = create(:meta_review_response_map, review_mapping: metareview_response1)
      response = create(:response, response_map: metareview_response2)
      expect(find_assignment_from_response_id(response.id)).to eq(response.response_map.review_mapping.review_mapping.assignment)
    end

    describe '.find_assignment_instructor' do
      # Makes use of existing :assignment and :course factories. Both point to Instructor.first

      it 'returns the instructor if the assignment belongs to a course' do
        instructor = create(:instructor).becomes(User)
        course = create(:course, instructor: instructor)
        assignment = create(:assignment, course: course, instructor: nil)
        expect(find_assignment_instructor(assignment)).to eq(assignment.course.instructor)
      end

      it 'returns the instructor if the assignment does not belong to a course' do
        instructor = create(:instructor).becomes(User)
        assignment = create(:assignment, course: nil, instructor: instructor)
        expect(find_assignment_instructor(assignment)).to eq(assignment.instructor)
      end
    end
  end
end
