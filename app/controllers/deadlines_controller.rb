class DeadlinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deadline, only: [:show, :estimate_duration]

  def show
  end

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

  private

  def set_deadline
    @deadline = Deadline.find(params[:id])
  end
end
