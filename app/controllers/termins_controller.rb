class TerminsController < ApplicationController
	def list
		@termin_new = Termin.new
		@termins = Termin.all().order(:date, :time)
		@todo = Termin.all().order(:id)
		@haikus = self.haiku
	end

	def create
	  @termin = Termin.create(post_params)
	  # here take apart @termine from form, parse out the date and time from :input and add to :date and :time
	  raw_to_db(@termin.input)
		if @termin.save
		    flash[:notice] = "Your time entry was incorrect"
			redirect_to :action => 'list', :error => "this is an error message"			
		end
	end
	
	
	def raw_to_db (raw_desc)
	## finished strings with :date :time and :msg values
	## outputs data = [db_date_string, termine_time, db_msg_string, formated_string] 
	## todo is formated so: "todo, msg"
	## termine is formated so: "30.10, 16:00, msg"

		formated_string = ""
		db_date_string = ""
		db_msg_string = ""
		termine_time = 0.01
		## takes entry and makes :date (2014 mo day) :time (as float 10.0) :msg attributes
		## get current date day and year
		current = DateTime.now
		month_current = current.month.to_i
		day_current = current.day.to_i
		year_current = current.year.to_i
		termine_year = year_current
		todo = 0 #flag for todo string type
		error = 0 #flag for error

        if not raw_desc.include? ","
			flash[:notice] = "Your entry was incorrect"

		end
        
		if raw_desc.include? "todo"   #this is a todo element without a date
			todo = 1 # flag that time won't be there in final string
		
			todo_split = raw_desc.split(",") 
			if todo_split.count != 2
			    flash[:notice] = "Your entry was incorrect"

			end
			db_msg_string = todo_split.last
			db_date_string = year_current.to_s + " " + month_current.to_s + " " + day_current.to_s
			@termin.todo = "1"
			termin_time = 0.01
			@termin.time = termin_time.to_s
			@termin.date = db_date_string
		else

			# raw_desc is not a todo item but a termine
			@termin.todo = "0"

			## build the :date element
			a = raw_desc.split(",")
			if a.count != 3
			    flash[:notice] = "Your entry was incorrect"
			end
			## get the msg
			db_msg_string = a.last
			## get the time if there element[1] when array is length = 3
			length = a.count
			if length > 2
			   if not a[1].include? ":"
					flash[:notice] = "Your time entry was incorrect"

		       end
			   temp_time = a[1].split(":")
			   temp_hour = temp_time[0]
			   temp_minute = temp_time[1]
			   temp_decimal = temp_hour + "." + temp_minute
			   termin_time = temp_decimal.to_f
			end
			if not a[0].include? "."
				flash[:notice] = "Your date entry was incorrect"

		    end
			date_dot = a[0].split(".")
			termine_day = date_dot[0].to_i
			if termine_day < 10
			   termine_day_str = '0'+termine_day.to_s
			else
			   termine_day_str = termine_day.to_s
			end
			termine_month = date_dot[1].to_i
			if termine_month < 10
			   termine_month_str = '0'+ termine_month.to_s
			else
			   termine_month_str = termine_month.to_s
			end
			# check if year should be next year
				if termine_month <= month_current and termine_day < day_current
					termine_year = year_current + 1
				end
	
			## format the date for db :date
			db_date_string = termine_year.to_s + " " + termine_month_str + " " + termine_day_str + " "
		
			@termin.time = termin_time.to_s
			@termin.date = db_date_string
		end
	
		## now make the formated_string for display on screen
		if todo > 0  ## this is a todo item
		   @termin.formated_string = db_msg_string
		else
		   temp_date = @termin.date
		   split_date = temp_date.split(" ")
		   month = split_date[1]
		   day = split_date[2]
		   if month.to_i < 10 and month.to_s.length < 2
			  month = "0" + month
		   end
		   if day.to_i < 10 and day.to_s.length < 2
			  day = "0" + day
		   end
		   temp_time = @termin.time
		   split_time = temp_time.split(".")
		   if split_time[1].to_i < 10 and split_time[1].to_s.length < 2
			  minutes = split_time[1].to_s + "0"
		   else
			  minutes = split_time[1]
		   end
		   hours = split_time[0]
		   time_string = hours + ":" + minutes
		   msg_for_screen = day + "." + month + " at " + time_string + " => " + db_msg_string
		   @termin.formated_string = msg_for_screen

		end
	
	end
	
	
	
	def haiku
	    preposition = ["at", "on", "in", "before"]
		noun = ["sun", "moon", "tree", "forest", "sea", "pond", "mountain", "field", "star", "whisper", "bird", "butterfly", "cocoon", "deer", "wolf"]
		verb = ["runs", "falls", "turns", "swings", "drops", "flies", "shoots", "sways", "swims", "tumbles", "chases", "hurries"]
		adjective = ["bright", "dark", "shady", "thin", "golden", "loud", "silver", "red", "thick", "tender", "silent", "constant", "changed", "misty", "foggy"]
		adverb = ["quietly", "suddenly", "quickly", "tenderly", "secretly", "slowly"]
 
		line_one = "#{preposition[Random.rand(preposition.length)]} the #{noun[Random.rand(noun.length)]}"
		line_two = "a #{noun[Random.rand(noun.length)]} #{verb[Random.rand(verb.length)]}"
		line_three = "a #{adjective[Random.rand(adjective.length)]} #{noun[Random.rand(noun.length)]}"
		
		return haiku_out = [line_one, line_two, line_three]
	end
	
	def delete
		Termin.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
	
	def new
		@termin = Termin.new
	end

	private
	def post_params
	    ## This says that params[:post] is required, but inside that, only params[:post][:title] and params[:post][:body] are permitted
	    ## Unpermitted params will be stripped out
		params.require(:termin).permit(:input, :date, :time, :todo, :formated_string)
	end  
end
