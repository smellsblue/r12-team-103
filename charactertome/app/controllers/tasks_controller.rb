class TasksController < ApplicationController
  def create
    @tome = Tome.find params[:tome_id]
    raise "You do not have permission!" if session[:user_id].to_i != @tome.owner.id
    goal = Goal.find params[:goal_id]
    raise "That is not the right goal id!" if goal.tome_id != @tome.id
    result = @tome.create_task! goal, params
    render :json => {
      :html => render_to_string(:partial => "/tomes/task", :object => result[:task], :format => :html)
    }
  end

  def update
    render :json => {}
  end
end
