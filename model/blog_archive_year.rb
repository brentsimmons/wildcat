require 'date'

class BlogArchiveYear

	attr_reader :year
	attr_reader :months

	def initialize(year)

		@year = year
		@months = []
	end

	def add_month(month_num)

		if !@months.include?(month_num)
			@months.push(month_num)
		end
	end
end
