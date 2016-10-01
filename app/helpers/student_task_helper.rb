module StudentTaskHelper
	def get_review_grade_info(participant)
		info = ''
		if participant.try(:grade_for_reviewer).nil? or participant.try(:comment_for_reviewer).nil?
            result = "N/A"
        else
			info = "Score: " + participant.try(:grade_for_reviewer).to_s + "\n"
			info += "Comment: " + participant.try(:comment_for_reviewer).to_s
			info = truncate(info, length: 1500, omission: '...')
			result = "<img src = '/assets/info.png' title = '" + info + "'>"
		end
		result.html_safe
	end
end
