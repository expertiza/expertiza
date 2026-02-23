# app/services/llm_evaluation_service.rb
require "openai"

class LlmEvaluationService
    def self.call(params)
      # Later: Build request payload from actual data
  
      # For now: Return dummy structured data
      # {
      #   reviewers: [
      #     {
      #       reviewer_id: 1,
      #       reviewer_name: "John Doe",
      #       unity_id: "jdoe",
      #       reviews_done: "2/3",
      #       reviewed_teams: [
      #         { team_name: "Team1", reviewed: true, score_awarded: 85, average_score: 80 },
      #         { team_name: "Team2", reviewed: false, score_awarded: nil, average_score: nil }
      #       ],
      #       metrics: "35 words",
      #       review_grade: {
      #         grade_for_reviewer: 90,
      #         comment_for_reviewer: "Good effort!"
      #       }
      #     },
      #     {
      #       reviewer_id: 2,
      #       reviewer_name: "Jane Smith",
      #       unity_id: "jsmith",
      #       reviews_done: "3/3",
      #       reviewed_teams: [
      #         { team_name: "Team3", reviewed: true, score_awarded: 95, average_score: 93 },
      #         { team_name: "Team4", reviewed: true, score_awarded: 90, average_score: 89 }
      #       ],
      #       metrics: "42 words",
      #       review_grade: {
      #         grade_for_reviewer: 88,
      #         comment_for_reviewer: "Detailed feedback."
      #       }
      #     }
      #   ]
      # }


      assignment = Assignment.find(params[:id])
      reviewers = assignment.participants.includes(:reviews_given)

      # client = OpenAI::Client.new(bearer_token: <YOUR-API-KEY>)

      reviewers.map do |reviewer|
        review_text = gather_review_texts(reviewer)
        prompt = <<~PROMPT
          Evaluate the following peer reviews for quality, depth, and helpfulness:
          ---
          #{review_text}
          ---
          Respond with a score out of 100 and a comment summary.
          Format: {"grade_for_reviewer": number, "comment_for_reviewer": "string"}
        PROMPT

        begin
          response = client.chat(
            parameters: {
              model: "gpt-4",
              messages: [{ role: "user", content: prompt }],
              temperature: 0.5
            }
          )

          parsed = JSON.parse(response.dig("choices", 0, "message", "content"))
          {
            reviewer_id: reviewer.id,
            reviewer_name: reviewer.name,
            unity_id: reviewer.fullname,
            reviews_done: "#{reviewer.reviews_given.count}/#{assignment.num_reviews_required}",
            reviewed_teams: [], # Fill this if needed
            metrics: "#{review_text.split.size} words",
            review_grade: parsed
          }

        rescue JSON::ParserError => e
          {
            reviewer_id: reviewer.id,
            reviewer_name: reviewer.name,
            unity_id: reviewer.fullname,
            error: "Failed to parse GPT response"
          }
        end
      end

      def self.gather_review_texts(reviewer)
        reviewer.reviews_given.map(&:get_all_review_comments).join("\n\n")
      end
    end
  end
  