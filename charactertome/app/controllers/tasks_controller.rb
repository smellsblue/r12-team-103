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
    @tome = Tome.find params[:tome_id]
    raise "You do not have permission!" if session[:user_id].to_i != @tome.owner.id
    goal = Goal.find params[:goal_id]
    raise "That is not the right goal id!" if goal.tome_id != @tome.id
    task = Task.find params[:id]
    raise "That is not the right task id!" if task.goal_id != goal.id
    result = @tome.update_task! task, params
    render :json => {
      :task_completed_status => task.completed_status,
      :goal_completed_percent => goal.accomplished_percent
    }
  end
end