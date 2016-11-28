module MessagesHelper
def self_or_other(message)
    message.user == current_user ? "self" : "other"
  end
end
