class DeadlinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deadline, only: [:show, :estimate_duration]

  def show
  end

  def estimate_duration
    prompt = <<~PROMPT
      Tu es un assistant IA spécialisé en gestion de projet.

      L'utilisateur veut estimer la durée d'une tâche.

      Voici la tâche :
      Titre : #{@deadline.title}
      Description : #{@deadline.description}
      Catégorie : #{@deadline.category}
      Date limite : #{@deadline.due_date}

      Ta mission :
      1. Pose les questions de précision utiles si certaines informations manquent.
      2. Propose ensuite une estimation réaliste de durée en minutes.
      3. Termine par une phrase au format exact :
      ESTIMATION_MINUTES: nombre

      Réponds en français, de façon claire et concise.
    PROMPT

    response = RubyLLM.chat.ask(prompt)

    @ai_response = response.content

    estimated_duration = @ai_response[/ESTIMATION_MINUTES:\s*(\d+)/, 1]

    if estimated_duration.present?
      @deadline.update(estimated_duration: estimated_duration.to_i)
    end

    flash.now[:notice] = "Réponse IA générée."
    render :show, status: :ok
  end

  private

  def set_deadline
    @deadline = Deadline.find(params[:id])
  end
end
