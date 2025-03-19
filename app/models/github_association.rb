class GithubAssociation < ApplicationRecord
    validates :expertiza_username, presence: true, uniqueness: { scope: :github_user }
    validates :github_user, presence: true

    # Associate a github username with expertiza username and save the association in the database
    def self.import(row_hash, _row_header, session, _id = nil)
        raise ArgumentError, "Only #{row_hash.length} column(s) is(are) found. It must contain at least expertiza_username, github_user." if row_hash.length < 2
    
        user = User.find_by_name(row_hash[:expertiza_username])
        if !user.nil?
          @github_association = GithubAssociation.new
          @github_association.github_user = row_hash[:github_user]
          @github_association.expertiza_username = row_hash[:expertiza_username]
          @github_association.save
        end
      end
end
