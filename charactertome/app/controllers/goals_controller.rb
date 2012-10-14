class GoalsController < ApplicationController
  def create
    @tome = Tome.find params[:tome_id]
    raise "You do not have permission!" if session[:user_id].to_i != @tome.owner.id
    result = @tome.create_goal! params
    render :json => {
      :new_goal_html => render_to_string(:partial => "/tomes/goal", :object => result[:goal], :format => :html)
    }
  end

  def update
    render :json => {}
  end
end
