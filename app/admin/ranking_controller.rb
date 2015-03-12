class RankingController < ActionController::Base

	def self.mark_semifinalists
		## 1 team moves on if <= 10 people
		## 2 teams move on if 11 - 20 people

		## for every event
		## calculate number of teams advancing
		## sort the teams by the to p average score

		# http://stackoverflow.com/questions/19339140/ruby-on-rails-order-users-based-on-average-ratings-with-most-reviews
		#Team.joins(:rubrics).select("teams.id, AVG(rubrics.score) as avg_score, count(rubrics.id) as num_rubrics").group("teams.id").order("avg_score DESC")

		# Team.update_all(issemifinalist:false)
		# for e in Event.all
		# 	num_teams = [0, (e.teams.length-1)/10 + 1].max
		# 	winners = Team.where(event_id: e.id).joins(:rubrics).select("teams.id, AVG(rubrics.score) as avgscore").group("teams.id").order("avgscore DESC").limit(num_teams)
		# 	winners.update_all(issemifinalist:true)
		# end

		Team.update_all(issemifinalist:false)
		for e in Event.all
			num_teams = [0, (e.teams.length-1)/10 + 1].max
			winners = e.teams.sort_by(&:avg_score).take(num_teams).each { |w|
				w.update(issemifinalist: true)				
			}
		end
	end

	def self.mark_finalists
		## the top N scores per region
		Team.update_all(isfinalist:false)
		for r in Team.regions
			num_teams = self.num_finalists(r)
			region_id = Team.regions[r]
			winners = Team.has_region(region_id).sort_by(&:avg_score).take(num_teams).each { |w|
				w.update(isfinalist:true)
			}
		end
	end

	def self.mark_winners
		## 1 hs winner and 1 ms winner
		hs = ['ushs', 'mexicohs', 'europehs', 'africahs'].map{|x| Team.regions[x]}
		ms = ['usms', 'mexicoms', 'europems'].map{|x| Team.regions[x]}

		Team.update_all(iswinner:false)
		Team.where(region: hs).sort_by(&:avg_score).take(1).each{ |w| w.update(iswinner:true) }
		Team.where(region: ms).sort_by(&:avg_score).take(1).each{ |w| w.update(iswinner:true) }
	end

	def self.num_finalists(region)
		case region[0].to_sym
		when :ushs
		  3
		when :mexicohs
		  1
		when :europehs
		  1    
		when :africahs
		  1
		when :usms
		  2
		when :mexicoms
		  1
		when :europems
		  1
		else
		  "Error"
		end
	end
	
	# def self.batch_ready?(event)
	# 	## returns true if all submissions have at least 3 scores
	# end

	## we don't have fine enough location information to do this
	# def assign_event(region, event)
	# 	## assign unassigned(?)
	# end

end