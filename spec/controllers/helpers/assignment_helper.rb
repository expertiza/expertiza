module AssignmentHelper
def assignment1
Assignment.where(name: 'assignment1').first || Assignment.new({
    "id"=> "101",
    "name"=>"My assignment",
    "is_intelligent"=>1
    })
end
end