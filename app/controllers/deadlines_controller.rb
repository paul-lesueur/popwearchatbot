class DeadlinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deadline, only: %i[show update destroy estimate_duration]

  def estimate_duration
    prompt = <<~PROMPT
      Tu es un assistant IA spécialisé en organisation et gestion du temps.

      L'utilisateur veut estimer la durée nécessaire pour réaliser une tâche.

      Informations connues :
      - Titre : #{@deadline.title}
      - Description : #{@deadline.description}
      - Catégorie : #{@deadline.category}
      - Date limite : #{@deadline.due_date}

      Ta mission :
      1. Analyse la tâche.
      2. Pose les questions de précision qui seraient utiles avant d'estimer précisément la durée.
      3. Donne quand même une première estimation prudente de durée.
      4. Termine obligatoirement ta réponse par une ligne au format exact :
      ESTIMATION_MINUTES: nombre

      Contraintes :
      - Réponds en français.
      - Sois clair et concis.
      - Le nombre doit être un entier en minutes.
      - Ne mets aucun texte après la ligne ESTIMATION_MINUTES.
    PROMPT

    response = RubyLLM.chat(model: "gpt-4o").ask(prompt)

    @ai_response = response.content
    estimated_duration = @ai_response[/ESTIMATION_MINUTES:\s*(\d+)/, 1]

    if estimated_duration.present?
      @deadline.update(estimated_duration: estimated_duration.to_i)
    end

    redirect_to deadline_path(@deadline), notice: "Estimation IA générée."
  end

  def index
    @deadlines = current_user.deadlines.order(:due_date)
    @deadlines = @deadlines.where(category: params[:category]) if params[:category].present?
  end

  def show
    set_client_message
  end

  def new
    @deadline = current_user.deadlines.new(due_date: Date.today, status: "todo")
  end

  def create
    @deadline = current_user.deadlines.new(deadline_params)

    if @deadline.save
      redirect_to deadline_path(@deadline), notice: "Échéance créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @deadline.update(deadline_params)
      redirect_to deadline_path(@deadline), notice: "Échéance mise à jour."
    else
      set_client_message
      render :show, status: :unprocessable_entity
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

  def set_client_message
    @client_message = Message.joins(:chat)
                             .where(chats: { deadline_id: @deadline.id, user_id: current_user.id })
                             .where(role: "assistant")
                             .order(created_at: :desc)
                             .first
  end

  def deadline_params
    params.require(:deadline).permit(
      :title,
      :description,
      :category,
      :due_date,
      :status,
      :estimated_duration
    )
  end
end
