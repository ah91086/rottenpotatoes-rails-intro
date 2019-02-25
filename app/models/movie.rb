class Movie < ActiveRecord::Base
	def self.get_ratings
		['G','PG','PG-13','R']
	end

	def self.with_ratings (ratings, orderBy)
		if orderBy == nil
			Movie.where(rating: ratings)
		else
			this = Movie.where(rating: ratings).order(orderBy)
		end
	end
end
