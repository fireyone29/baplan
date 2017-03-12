# Controller for manipulating goals.
class GoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_authorized_goal, only: [:show, :edit, :update, :destroy]
  after_action :save_previous_url, only: [:edit]

  # GET /goals
  # GET /goals.json
  def index
    @goals = Goal.where(user_id: current_user.id).order('id ASC')
  end

  # GET /goals/1
  # GET /goals/1.json
  def show(); end

  # GET /goals/new
  def new
    @goal = Goal.new
  end

  # GET /goals/1/edit
  def edit(); end

  # POST /goals
  # POST /goals.json
  def create
    @goal = Goal.new(goal_params)
    @goal.user_id = current_user.id

    respond_to do |format|
      if @goal.save
        notice = 'Goal was successfully created.'
        format.html { redirect_to @goal, notice: notice }
        format.json { render :show, status: :created, location: @goal }
      else
        format.html { render :new }
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goals/1
  # PATCH/PUT /goals/1.json
  def update
    respond_to do |format|
      if @goal.update(goal_params)
        notice = 'Goal was successfully updated.'
        format.html { redirect_to session[:goals_previous_url], notice: notice }
        format.json { render :show, status: :ok, location: @goal }
      else
        format.html { render :edit }
        format.json { render json: @goal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goals/1
  # DELETE /goals/1.json
  def destroy
    @goal.destroy
    respond_to do |format|
      notice = 'Goal was successfully destroyed.'
      format.html { redirect_to goals_url, notice: notice }
      format.json { head :no_content }
    end
  end

  private

  # Make the relevant goal available.
  #
  # Alert and redirect if the goal doesn't belong to the user.
  def set_authorized_goal
    @goal = Goal.includes(:latest_streak, :user).find(params[:id])

    # where a particular goal is set, require it to belong to the
    # logged in user
    opts = { alert: 'You do not have access to that!' }
    redirect_to(goals_url, opts) unless current_user == @goal.user
  end

  # Never trust parameters from the scary internet, only allow the
  # white list through.
  def goal_params
    params.require(:goal).permit(:description, :frequency)
  end

  # Save the referrer from the form controllers.
  def save_previous_url
    session[:goals_previous_url] = URI(request.referer || '').path
  end
end
