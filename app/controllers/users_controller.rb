# encoding: utf-8

class UsersController < ApplicationController
  include StatsHelper

  before_filter :require_admin_or_reviewer, only: :reviews
  before_filter :require_admin, only: [:index, :toggle_reviewer, :toggle_admin]

  # retrieve user from URL
  before_filter :get_user, except: [:index, :new, :create]
  # i.e. user from URL is equal to the one logged in
  before_filter :signed_in_user, only: [:edit, :update, :enroll, :starred, :history, :destroy]
  before_filter :correct_user,   only: [:edit, :update, :enroll, :starred, :history]


  def index
    @users = User.where(admin: false, reviewer: false)
    @stat_counts = Stat.group(:user_id).count

    @admins = User.where('admin=? OR reviewer=?', true, true)
  end

  def reviews
    @reviews = @user.reviews.includes(:question).limit(REVIEW_MAX_OWN_REVIEWS)
  end

  def toggle_reviewer
    return toggle_attr(:reviewer)
  end

  def toggle_admin
    if SUPERADMIN.include?(@user.nick)
      flash[:error] = "Netter Versuch. Superadmins können nicht ohne weiteres den Admin-Status aberkannt bekommen."
      return redirect_to user_index_path
    end

    return toggle_attr(:admin)
  end

  def starred
    fresh_when(etag: etag(@user.starred.pluck(:id).join("_")))
  end

  def history
    @stats = @user.stats.includes(:question => [:answers]).find(:all, :order => "created_at DESC", :limit => 50)
  end

  def new
    @user = User.new
  end

  def create
    nick = params[:user][:nick]
    params[:user].delete(:nick)
    @user = User.new(params[:user])
    @user.nick = nick
    if @user.save
      sign_in @user
      flash[:success] = "Du bist jetzt angemeldet. Diese Seite ist Deine Profilseite. Hier kannst Du auch einen Einschreibeschlüssel eintragen, wenn Dir einer mitgeteilt wurde."
      redirect_to edit_user_path(@user)
    else
      render 'new'
    end
  end

  def edit
    chart
  end

  def enroll
    key = (params[:enrollment_key] || '').gsub(/[^a-z0-9]/i, "")
    if key.blank?
      flash[:error] = "Kein Einschreibeschlüssel angegeben."
      chart
      render 'edit'
    elsif @user.enrollment_keys && @user.enrollment_keys.split.include?(key)
      flash[:warning] = "In diese Veranstaltung bist Du schon eingeschrieben."
      redirect_to edit_user_path(@user)
    elsif !EnrollmentKeys.names.include?(key)
      flash[:error] = "Dieser Einschreibeschlüssel ist unbekannt. Die Groß-/Kleinschreibung zählt."
      chart
      render 'edit'
    else
      @user.enrollment_keys ||= ""
      @user.enrollment_keys += " #{key}"
      if @user.save
        flash[:success] = "Erfolgreich in #{key} eingeschrieben."
        sign_in @user
        redirect_to edit_user_path(@user)
      else
        flash[:error] = "Konnte Dich nicht in #{key} einschreiben. Bitte kontaktiere eine in der Hilfe aufgelistete Person."
        chart
        render 'edit'
      end
    end
  end

  def update
    @user.updating_password = params[:type] == 'pwchange'

    if @user.update_attributes(params[:user])
      flash[:success] = "Nutzerdaten aktualisiert"
      sign_in @user
      redirect_to edit_user_path(@user)
    else
      chart
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "Deine Daten wurden gelöscht. Beehre uns bald wieder."
    redirect_to root_url
  end

  private

  def correct_user
    logger.warn "correct_user: @user: #{@user.nick}"
    redirect_to(root_url) unless current_user?(@user)
  end

  def get_user
    @user = User.find(params[:id]) rescue nil

    unless @user
      logger.warn "get_user failed with id=#{params[:id]}"
      flash[:error] = "Nutzer mit id=#{params[:id]} nicht gefunden."
      return redirect_to (admin? ? user_index_path : signin_path)
    end
  end


  def chart
    # data for the last 91 days, grouped in 7 days makes 13 buckets
    data = { right: [0]*13, wrong: [0]*13, skipped: [0]*13}

    # user stats are not scoped by time
    last_stats = @user.stats.where("created_at > ?", 91.days.ago)

    time = Time.now
    last_stats.each do |stat|
      insert_stat_in_hash(stat, data, time)
    end

    percent_correct, percent_skipped = raw_to_percentage(data)

    @h = render_graph
    @h.series(:name=>'Richtig beantwortete Fragen', :data => percent_correct)
    @h.series(:name=>'Übersprungene Fragen', :data => percent_skipped)
  end

  private

  def toggle_attr(attr)
    raise "attr must be symbol" unless attr.is_a?(Symbol)
    name = attr.to_s.humanize
    # skip before_save callbacks to keep the user signed in (avoid re-
    # generating remember_token)
    if @user.update_column(attr, !@user.send(attr))
      flash[:success] = "#{@user.nick} ist #{@user.send(attr) ? "jetzt #{name}" : "kein #{name} mehr"}."
    else
      flash[:error] = "Konnte den #{name}-Status für #{@user.nick} nicht umschalten."
    end

    redirect_to user_index_path
  end
end
