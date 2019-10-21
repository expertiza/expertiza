
oss code change files
oss code change files
100%
    11
To enable screen reader support, press Ctrl+Alt+Z To learn about keyboard shortcuts, press Ctrl+slash
Expertiza::Application.routes.draw‌ ‌do‌ ‌
‌###‌ ‌
‌#‌ ‌Please‌ ‌insert‌ ‌new‌ ‌routes‌ ‌alphabetically!‌ ‌
‌###‌ ‌
‌require‌ ‌'sidekiq/web'‌ ‌
‌mount‌ ‌Sidekiq::Web‌ ‌=>‌ ‌'/sidekiq'‌ ‌
‌
‌resources‌ ‌:admin,‌ ‌only:‌ ‌[]‌ ‌do‌ ‌
‌collection‌ ‌do‌ ‌
‌get‌ ‌:list_super_administrators‌ ‌
‌get‌ ‌:list_administrators‌ ‌
‌get‌ ‌:list_instructors‌ ‌
‌post‌ ‌:create_instructor‌ ‌
‌get‌ ‌:remove_instructor‌ ‌
‌post‌ ‌:remove_instructor‌ ‌
‌get‌ ‌:show_instructor‌ ‌
‌end‌ ‌
‌end‌ ‌
‌
‌resources‌ ‌:advertise_for_partner,‌ ‌only:‌ ‌%i[new‌ ‌create‌ ‌edit‌ ‌update]‌ ‌do‌ ‌
‌collection‌ ‌do‌ ‌
‌get‌ ‌:remove‌ ‌
‌post‌ ‌':id',‌ ‌action:‌ ‌:update‌ ‌
‌end‌ ‌
‌end‌ ‌
‌
‌resources‌ ‌:advice,‌ ‌only:‌ ‌[]‌ ‌do‌ ‌
‌collection‌ ‌do‌ ‌
‌post‌ ‌:save_advice‌ ‌
‌end‌ ‌
‌end‌ ‌
‌
‌resources‌ ‌:answer‌ ‌
‌
‌resources‌ ‌:answer_tags,‌ ‌only:‌ ‌[:index]‌ ‌do‌ ‌
‌collection‌ ‌do‌ ‌
‌post‌ ‌:create_edit‌ ‌
‌end‌ ‌
‌end‌ ‌
‌
‌resources‌ ‌:assessment360,‌ ‌only:‌ ‌[]‌ ‌do‌ ‌
‌collection‌ ‌do‌ ‌
‌get‌ ‌:course_student_grade_summary‌ ‌
Toggle screen reader support
