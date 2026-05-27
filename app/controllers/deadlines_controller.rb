class DeadlinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deadline, only: %i[show edit update destroy estimate_duration]

  def estimate_duration
  prompt = <<~PROMPT
  Tu es un assistant IA spécialisé dans l'organisation d'un atelier de couture, retouche et cordonnerie.

  Tu dois estimer le temps nécessaire pour réaliser une tâche artisanale.

  Informations de l'échéance :
  - Titre : #{@deadline.title}
  - Description : #{@deadline.description}
  - Catégorie : #{@deadline.category}
  - Date limite : #{@deadline.due_date}

  Grille indicative de durées :
  - Ourlet simple : 20 à 40 minutes
  - Retouche légère : 30 à 60 minutes
  - Retouche complexe : 60 à 120 minutes
  - Fermeture éclair : 45 à 90 minutes
  - Réparation couture simple : 30 à 60 minutes
  - Réparation couture complexe : 60 à 120 minutes
  - Ressemelage ou réparation cordonnerie simple : 60 à 120 minutes
  - Réparation cordonnerie complexe : 120 à 240 minutes
  - Préparation de commande client : 15 à 45 minutes
  - Tâche administrative simple : 15 à 45 minutes
  - Tâche comptable simple : 30 à 90 minutes
  - Tâche floue ou peu détaillée : estimation prudente entre 45 et 90 minutes

  Ta mission :
  1. Analyse le titre, la description, la catégorie et la date limite.
  2. Identifie le type de tâche.
  3. Donne une estimation réaliste pour un artisan seul.
  4. Ne sois pas trop optimiste.
  5. Si les informations sont insuffisantes, choisis une estimation prudente.
  6. Affiche la durée estimée en heures et minutes dans ta réponse visible.
  7. Termine obligatoirement ta réponse par une ligne au format exact :
  ESTIMATION_MINUTES: nombre

  Format attendu :
  - Une courte analyse de la tâche.
  - Une estimation lisible sous la forme : "Durée estimée : X h Y min".
  - Une dernière ligne obligatoire avec le total en minutes.

  Exemple :
  Cette tâche semble demander une préparation, une vérification et une exécution soigneuse. Une estimation prudente serait donc de 2 h 30 min.

  Durée estimée : 2 h 30 min

  ESTIMATION_MINUTES: 150

  Contraintes :
  - Réponds en français.
  - Sois clair et concis.
  - Le nombre dans ESTIMATION_MINUTES doit être un entier.
  - ESTIMATION_MINUTES doit contenir uniquement le total en minutes.
  - Ne mets aucun texte après la ligne ESTIMATION_MINUTES.
  PROMPT

    response = RubyLLM.chat(model: "gpt-4o").ask(prompt)

    @ai_response = response.content
    estimated_duration = @ai_response[/ESTIMATION_MINUTES:\s*(\d+)/, 1]

    if estimated_duration.present?
      @deadline.update(estimated_duration: estimated_duration.to_i)
    end

    redirect_to edit_deadline_path(@deadline), notice: "Estimation IA générée."
  end

  def index
    @deadlines = current_user.deadlines.order(:due_date)
    @deadlines = @deadlines.where(category: params[:category]) if params[:category].present?
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
