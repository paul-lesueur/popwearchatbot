class DeadlinesController < ApplicationController
  before_action :set_deadline, only: %i[show edit update destroy]

  def index
    @deadlines = current_user.deadlines.order(:due_date)
  end

  def show
  end

  def new
    @deadline = current_user.deadlines.new(due_date: Date.today, status: "todo")
  end

  def create
    @deadline = current_user.deadlines.new(deadline_params)
    if @deadline.save
      redirect_to deadlines_path, notice: "Échéance créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @deadline.update(deadline_params)
      redirect_to deadlines_path, notice: "Échéance mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deadline.destroy
    redirect_to deadlines_path, notice: "Échéance supprimée."
  end

  private

  def set_deadline
    @deadline = current_user.deadlines.find(params[:id])
  end

  def deadline_params
    params.require(:deadline).permit(:title, :description, :category, :due_date, :status)
  end
end
