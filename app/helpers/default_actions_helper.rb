# encoding: utf-8

module DefaultActionsHelper
  def update
    model, obj, name, human = get_subject_variables

    if obj && obj.update_attributes(params[name])
      flash[:success] = "#{human} aktualisiert"
      redirect_to @question || @category
    else
      render 'edit'
    end
  end

  def destroy
    model, obj, name, human = get_subject_variables

    if obj && obj.destroy
      flash[:success] = "#{human} gelöscht"
    else
      flash[:error] = "#{human} nicht gelöscht. Siehe Log für mehr Informationen."
    end
    redirect_to @question || categories_path
  end

  def edit
    model, obj, name, human = get_subject_variables

    unless obj
      flash[:warning] = "#{human} nicht gefunden. Hast Du evtl. einen alten Link angeklickt?"
      return redirect_to @question || categories_path
    end
  end

  def create
    model, obj, name, human = get_subject_variables

    obj = model.new(params[name])
    obj.question = @question if obj.respond_to?("question=")
    instance_variable_set("@#{name}", obj)

    if obj.save
      flash[:success] = "#{human} gespeichert"
      redirect_to @question || obj
    else
      render 'new'
    end
  end

  def new
    model, obj, name, human = get_subject_variables

    instance_variable_set("@#{name}", model.new)
  end

  def get_subject_variables
    model = controller_name.classify.constantize
    name = controller_name.classify.downcase.to_sym
    human = model.model_name.human
    obj =  model.find(params[:id]) rescue nil
    obj = instance_variable_set("@#{name}", obj)
    return model, obj, name, human
  end
end
