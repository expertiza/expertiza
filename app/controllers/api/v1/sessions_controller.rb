require 'jwt'
module Api::V1
    class SessionsController <  BasicApiController 
        skip_before_action :verify_authenticity_token 
        skip_before_action :authenticate, only: [:create]
    
        def create
            user = User.find_by(name: auth_params[:name])
            if user && user.valid_password?(auth_params[:password])
            jwt = JWT.encode( {user: user.id , exp: (Time.now + 1.week).to_i },
                                Rails.application.secrets.secret_key_base,
                                'HS256')
            render json: {jwt: jwt}
            else
                head(:unauthorized)
            end
        end
        

        def index
            render json: {status: :ok, user: User.find(6)}
        end
        

        def destroy

        end

        private
        def auth_params
        params.require(:auth).permit( :password, :name)
        end
    end
end

 #<User id: 2, name: "super_administrator2", crypted_password: "f3488c791e5b153ddea3fa64a9e4134fcb48d2ef", role_id: 4, password_salt: "tUltQGRzGp8tih1t9jfu", fullname: "2, super_administrator", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: true, email_on_review_of_review: true, is_new_user: false, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "65096ca6c66fac1b1e9b71fcc4ba6d5d92103976619211ab7f...", timezonepref: "Eastern Time (US & Canada)", public_key: nil, copy_of_emails: false, institution_id: 1>,
  #<User id: 3, name: "instructor3", crypted_password: "6819c7d32db809ee7f8d05864e92b8b6aef26de5", role_id: 2, password_salt: "GP8eFwRhI7QlYOseu5xb", fullname: "3, instructor", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: true, email_on_review_of_review: false, is_new_user: true, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "0a2c1474458caee78c801ac31380a8a710c97a2d1fd6344327...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: nil>, 
  #<User id: 4, name: "instructor4", crypted_password: "358b8178b454dce2c6d0185084671bcd638656cc", role_id: 2, password_salt: "29SQbNqQGYjyCDGmBxY", fullname: "4, instructor", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: true, email_on_review_of_review: true, is_new_user: false, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "2252c3cbdfcd599c153b0b8d3d3ec5b2fecc970708cd9cafaa...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: 1>, 
  #<User id: 5, name: "administrator5", crypted_password: "b537f5cd59e7ad07b4decd833e38deed58561807", role_id: 3, password_salt: "veL7x9UUWcDvj3hggX", fullname: "5, administrator", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: true, email_on_review_of_review: true, is_new_user: true, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "9311493a0c39afc93e3bd40cd4c780a5c1abdac22a486ab597...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: nil>, 
  #<User id: 6, name: "instructor6", crypted_password: "e7f3d0752952df86cc268ed03278964db61aea25", role_id: 2, password_salt: "KgcadtejpNQa76umTPz3", fullname: "6, instructor", email: "9777", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: true, email_on_review_of_review: true, is_new_user: false, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "f17b05eafdde81113707942fa0f59a4449c99011ea97b8aa25...", timezonepref: "Eastern Time (US & Canada)", public_key: nil, copy_of_emails: false, institution_id: 1>, 
  #<User id: 7, name: "student7", crypted_password: "8d21bdf37371913edb5659f4c2378884966235e7", role_id: 1, password_salt: "b3TPdGHQdlC3nL9anEu", fullname: "7, student", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: false, email_on_review_of_review: false, is_new_user: true, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "f12790501e028d83d865f50d14f9438c3096e201f5ac05c888...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: 1>, 
  #<User id: 8, name: "student8", crypted_password: "d22a473652ec8e574fb32c7f52e80fa799333364", role_id: 1, password_salt: "xSdFn8LO6tkYjD543HjB", fullname: "8, student", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: false, email_on_review_of_review: true, is_new_user: true, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "af1096ca9b42c216f720d40eed808cb5cbb11eefd253c2c136...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: 1>, 
  #<User id: 9, name: "student9", crypted_password: "f43edcc50403b1713d42c36e4dda24b26d06fbab", role_id: 1, password_salt: "EGA9D5Awu7wskwFMsZ", fullname: "9, student", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: true, email_on_submission: true, email_on_review_of_review: true, is_new_user: false, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "4d7d3d3e911e9837c5ea7a7b16c13e9f9f39ff4013df6c53a6...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: 1>, 
  #<User id: 10, name: "student10", crypted_password: "bababcb88e94a05ec5a1d850749f5babed596e55", role_id: 1, password_salt: "eTMij8hqMGK6xQsUSlGn", fullname: "10, student", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: false, email_on_submission: false, email_on_review_of_review: false, is_new_user: true, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "cb15285c235289f38b203488ec37916fbc4a8f5df2e5f01333...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: 1>, 
  #<User id: 11, name: "student11", crypted_password: "3b72d8c924fb10bee3c8235bc3c202f25adf562b", role_id: 1, password_salt: "4cEgMfgzUEjCC28GOQj", fullname: "11, student", email: "expertiza@mailinator.com", parent_id: 2, private_by_default: false, mru_directory_path: nil, email_on_review: false, email_on_submission: false, email_on_review_of_review: false, is_new_user: false, master_permission_granted: 0, handle: "handle", digital_certificate: nil, persistence_token: "5e4972b19d39a4747083945e764a28b73730685e99797ffede...", timezonepref: nil, public_key: nil, copy_of_emails: false, institution_id: nil>, ...]>