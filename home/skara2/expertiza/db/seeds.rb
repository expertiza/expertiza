# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

library_list = [
    [1,"hunt", "Nc state", 14 ,"NCSU", 10,"2009-09-29 16:50:54", "2019-09-29 16:50:54" ],
    [2,"hill", "Nc state", 21 ,"NCSU", 5,"2009-09-29 16:50:54", "2019-09-29 16:50:54" ],
    [3,"none", "Nc state", 1 ,"NCSU", 1,"2009-09-29 16:50:54", "2019-09-29 16:50:54" ],]

book_list = [
    ["12 Rules For Life: An Antidote To Chaos", "Jordan B. Peterson" ,"English" ,"Random House Canada" ,2.4 ,"https://lh3.googleusercontent.com/hybLSyBKneLPX9jMU759oUVHE7W77-4bMonNoDVrlbNJW-1hxtemk54gkUHdWlFYOLOxIYov2MggOR8=s200-rw" ,"philosophy" ,"What does everyone in the modern world need to know? Renowned psychologist Jordan B. Peterson's answer to this most difficult of questions uniquely combines the hard-won truths of ancient tradition with the stunning revelations of cutting-edge scientific research.
" ,true ,1 ,"January 23, 2018","January 23, 2018"],
    ["Design Patterns: Elements of Reusable Object-Oriented Software","Addison-Wesley Professional", "English" , "Addison-Wesley Professional",1,"https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcSyTRIxDDLESccARKGeEny9sUSatpFjifJolUM4YXh2qED5ip3-8WrhvZ8kBaKWCLbz5Q6DHN2LnCSjYJHzB9R8BHIeEBNUsDzsNY37OmU&usqp=CAc","Design","Capturing a wealth of experience about the design of object-oriented software, four top-notch designers present a catalog of simple and succinct solutions to commonly occurring design problems. Previously undocumented, these 23 patterns allow designers to create more flexible, elegant, and ultimately reusable designs without having to rediscover the design solutions themselves.
", false, 2 ,"November 10, 1994", "November 10, 1994"]
]

library_list.each do |id,name, location, max_days, university, fine, created, updated|
  Library.create(id:id,l_name: name, l_location: location ,l_max_days:max_days ,l_university:university, l_fine:fine ,created_at:created ,updated_at:updated )
end

book_list.each do |b_title, b_author ,b_lang ,b_pub ,b_edition ,b_image ,b_subject ,b_summary ,b_spl ,index_books_on_Library_id ,created_at,updated_at|
  Book.create(b_title: b_title, b_author: b_author , b_lang: b_lang , b_pub: b_pub , b_edition: b_edition, b_image: b_image , b_subject: b_subject , b_summary: b_summary , b_spl: b_spl, available: true , Library_id: index_books_on_Library_id , created_at: created_at, updated_at: updated_at)
end

User.create!({email:"admin@admin.com",password:"admin123",reset_password_token:nil,reset_password_sent_at:'20120618 10:34:09 AM',remember_created_at:'20120618 10:34:09 AM',created_at:'20120618 10:34:09 AM',updated_at: '20120618 10:34:09 AM',user_type: "admin",u_name:"NCSU",library_id:nil,l_approved:true,s_education:"graduate",s_max:10})
User.create!({email:"st1@ncsu.com",password:"123456",reset_password_token:nil,reset_password_sent_at:'20120618 10:34:09 AM',remember_created_at:'20120618 10:34:09 AM',created_at:'20120618 10:34:09 AM',updated_at: '20120618 10:34:09 AM',user_type: "student",u_name:"NCSU",library_id:nil,l_approved:nil,s_education:"graduate",s_max:10})
User.create!({email:"st2@ncsu.com",password:"123456",reset_password_token:nil,reset_password_sent_at:'20120618 10:34:09 AM',remember_created_at:'20120618 10:34:09 AM',created_at:'20120618 10:34:09 AM',updated_at: '20120618 10:34:09 AM',user_type: "student",u_name:"NCSU",library_id:nil,l_approved:nil ,s_education:"graduate",s_max:10})
User.create!({email:"lib@ncsu.com",password:"123456",reset_password_token:nil,reset_password_sent_at:'20120618 10:34:09 AM',remember_created_at:'20120618 10:34:09 AM',created_at:'20120618 10:34:09 AM',updated_at: '20120618 10:34:09 AM',user_type: "librarian",u_name:"NCSU",library_id:nil,l_approved:nil,s_education:"graduate",s_max:10})



