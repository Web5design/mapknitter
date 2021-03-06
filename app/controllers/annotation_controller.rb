class AnnotationController < ApplicationController

	def create
		if logged_in?
			@note = Node.new(
				:body => params[:description],
				:lat => params[:lat],
				:lon => params[:lon],
				:map_id => params[:map_id],
				:author => current_user.login
				)
			@note.save!
			render :text => @note.id
		else
			flash[:error] = "You can't do that unless you're logged in."
			redirect_to "/home"
		end
	end

	def delete
		@note = Node.find params[:id]
		if logged_in? && (current_user.login == @note.author || current_user.role == "admin")
			@note.delete
			flash[:notice] = "Annotation deleted."
			redirect_to params[:back]
		else
			flash[:error] = "You can't do that unless you're logged in."
			redirect_to "/"
		end
	end

	def delete_poly
		@poly = Way.find params[:id]
		if logged_in? && (current_user.login == @poly.author || current_user.role == "admin")
			@nodes = Node.find_all_by_way_id @poly.id
			@nodes.each do |n|
				n.delete
			end
			@poly.destroy
			flash[:notice] = "Annotation deleted."
			redirect_to params[:back]
		else
			flash[:error] = "You can't do that unless you're logged in."
			redirect_to "/home"
		end
	end

	def index
		@notes = Node.find :all, :order => "id DESC", :conditions => ['map_id != 0 AND way_id = 0']
		@notes = @notes.paginate :page => params[:page], :per_page => 24
	end

	# POST
	# /annotation/create_poly?description=<description>&color=<color>&nodes=[{"lat":<lat>,"lon":<lon>}]
	def create_poly
		if logged_in?
			params[:color] ||= "red"
			@poly = Way.new(
				:body => params[:description],
				:author => current_user.login,
				:color => params[:color],
				:map_id => params[:map_id]
				)
			@poly.save!
			@nodes = params[:nodes]
			@nodes.each do |node|
				note = Node.new(
					:lat => node[1][0],
					:lon => node[1][1],
					:way_order => node[1][2],
					:way_id => @poly.id,
					:map_id => params[:map_id],
					:author => current_user.login
					)
				note.save!
			end
			render :text => @poly.id
		else
			flash[:error] = "You can't do that unless you're logged in."
			redirect_to "/home"
		end
	end

end
