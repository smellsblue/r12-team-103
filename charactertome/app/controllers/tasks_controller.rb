class TasksController < ApplicationController
  before_filter :verify_access_to_task

  def create
    result = @tome.create_task! @goal, params
    render :json => {
      :goal_id_for_new_task => @goal.id,
      :html => render_to_string(:partial => "/tomes/task", :object => result[:task], :format => :html),
      :goal_completed_percent => @goal.accomplished_percent,
      :goal_id => @goal.id
    }
  end

  def destroy
    raise "Task is required!" unless @task
    @task.destroy
    render :json => {
      :goal_completed_percent => @goal.accomplished_percent,
      :goal_id => @goal.id
    }
  end

  def update
    raise "Task is required!" unless @task
    result = @tome.update_task! @task, params
    render :json => {
      :task_completed_status => @task.completed_status,
      :completed_task_id => @task.id,
      :goal_completed_percent => @goal.accomplished_percent,
      :goal_id => @goal.id
    }
  end

  private
  def verify_access_to_task
    @tome = Tome.find params[:tome_id]
    raise "You do not have permission!" if session[:user_id].to_i != @tome.owner.id
    @goal = @tome.goals.find params[:goal_id]
    raise "That is not the right goal id!" if @goal.tome_id != @tome.id

    if params[:id].present?
      @task = @goal.tasks.find params[:id]
      raise "That is not the right task id!" if @task.goal_id != @goal.id\
    end
  end
end
