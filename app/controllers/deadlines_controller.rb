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

  def prefill
    task_description = params[:task_description]

    if task_description.blank?
      redirect_to new_deadline_path, alert: "Décris une tâche avant de demander le pré-remplissage."
      return
    end

    prompt = prefill_prompt(task_description)
    response = RubyLLM.chat(model: "gpt-4o").ask(prompt)

    ai_data = extract_json(response.content)

    redirect_to new_deadline_path(
      task_description: task_description,
      deadline: {
        title: ai_data["title"],
        description: ai_data["description"],
        category: valid_category(ai_data["category"]),
        due_date: valid_due_date(ai_data["due_date"]),
        status: valid_status(ai_data["status"]),
        estimated_duration: ai_data["estimated_duration"].to_i
      }
    ), notice: "Formulaire pré-rempli par l'IA. Vérifie les informations avant de créer l'échéance."
  rescue JSON::ParserError, TypeError
    redirect_to new_deadline_path(task_description: task_description),
                alert: "L'IA n'a pas renvoyé un format exploitable. Réessaie avec une description plus précise."
  end

  def index
    @deadlines = current_user.deadlines.order(:due_date)
    @deadlines = @deadlines.where(category: params[:category]) if params[:category].present?
  end

  def show
    @client_message = Message.joins(:chat)
                             .where(chats: { deadline_id: @deadline.id, user_id: current_user.id })
                             .where(role: "assistant")
                             .order(created_at: :desc)
                             .first
  end

  def new
    prefilled_attributes = if params[:deadline].present?
                             params.require(:deadline).permit(
                               :title,
                               :description,
                               :category,
                               :due_date,
                               :status,
                               :estimated_duration
                             )
                           else
                             {}
                           end

    @deadline = current_user.deadlines.new(prefilled_attributes)
    @deadline.due_date ||= Date.today
    @deadline.status ||= "todo"

    @ai_task_description = params[:task_description]
  end

  def create
    @deadline = current_user.deadlines.new(deadline_params)

    if @deadline.save
      redirect_to deadlines_path, notice: "Échéance créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @deadline.update(deadline_params)
      redirect_to deadline_path(@deadline), notice: "Échéance mise à jour."
    else
      @client_message = Message.joins(:chat)
                               .where(chats: { deadline_id: @deadline.id, user_id: current_user.id })
                               .where(role: "assistant")
                               .order(created_at: :desc)
                               .first

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

  def prefill_prompt(task_description)
    <<~PROMPT
      Tu es un assistant IA pour un artisan qui veut créer une échéance rapidement.

      L'artisan décrit une tâche en langage naturel.
      Ta mission est de transformer cette description en données propres pour remplir un formulaire Rails.

      Description donnée par l'artisan :
      #{task_description}

      Date du jour :
      #{Date.today}

      Catégories disponibles :
      #{Deadline.categories.keys.join(", ")}

      Statuts disponibles :
      #{Deadline.statuses.keys.join(", ")}

      Tu dois répondre uniquement avec un objet JSON valide, sans markdown, sans texte avant, sans texte après.

      Format obligatoire :
      {
        "title": "titre court et clair",
        "description": "description professionnelle de la tâche",
        "category": "une catégorie parmi les catégories disponibles",
        "due_date": "YYYY-MM-DD",
        "status": "todo",
        "estimated_duration": nombre_en_minutes
      }

      Règles :
      - Le titre doit être court.
      - La description doit être claire et utile.
      - La catégorie doit être exactement une des catégories disponibles.
      - Le statut doit être "todo" sauf si la description indique clairement autre chose.
      - La date doit être au format YYYY-MM-DD.
      - Si aucune date n'est donnée, choisis une date raisonnable proche.
      - La durée estimée doit être un nombre entier en minutes.
      - N'invente pas de détails excessifs.
      - Réponds uniquement avec le JSON.
    PROMPT
  end

  def extract_json(content)
    json_text = content.match(/\{.*\}/m)&.to_s

    raise JSON::ParserError, "Aucun JSON trouvé" if json_text.blank?

    JSON.parse(json_text)
  end

  def valid_category(category)
    if Deadline.categories.keys.include?(category)
      category
    else
      Deadline.categories.keys.first
    end
  end

  def valid_status(status)
    if Deadline.statuses.keys.include?(status)
      status
    else
      "todo"
    end
  end

  def valid_due_date(due_date)
    Date.parse(due_date.to_s)
  rescue ArgumentError, TypeError
    Date.today
  end
end
