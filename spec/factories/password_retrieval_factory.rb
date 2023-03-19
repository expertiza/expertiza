FactoryBot.define do
    factory :user, class: User do
        email { "factorybot@ncsu.edu" }
        fullname { "Factory Bot" }
        name { "factorybot" }
    end
    factory :password_reset, class: PasswordReset do
        user_email { "factorybot@ncsu.edu" }
        token { "factory_bot_token" }
    end
end