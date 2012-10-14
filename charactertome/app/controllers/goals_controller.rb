class GoalsController < ApplicationController
  before_filter :verify_access_to_goal

  def create
    result = @tome.create_goal! params
    render :json => {
      :new_goal_html => render_to_string(:partial => "/tomes/goal", :object => result[:goal], :format => :html)
    }
  end

  def destroy
    raise "Goal is required!" unless @goal
    raise "Goal cannot have any uncompleted tasks associated with it!" if @goal.has_uncompleted_tasks?
    @goal.tasks.destroy_all
    @goal.destroy
    render :json => {}
  end

  def update
    raise "Goal is required!" unless @goal
    render :json => @tome.update_goal!(@goal, params)
  end

  private
  def verify_access_to_goal
    @tome = Tome.find params[:tome_id]
    raise "You do not have permission!" if session[:user_id].to_i != @tome.owner.id

    if params[:id].present?
      @goal = @tome.goals.find params[:id]
      raise "That is not the right goal id!" if @goal.tome_id != @tome.id
    end
  end
end
