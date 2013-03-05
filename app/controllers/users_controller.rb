# encoding: utf-8

class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update, :destroy, :enroll, :starred]
  before_filter :correct_user,  only: [:edit, :update, :enroll, :starred]

  def starred
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
    if !key
      flash[:error] = "Kein Einschreibeschlüssel angegeben."
      render 'edit'
    elsif @user.enrollment_keys && @user.enrollment_keys.split.include?(key)
      flash[:warning] = "In diese Veranstaltung bist Du schon eingeschrieben."
      redirect_to edit_user_path(@user)
    elsif !EnrollmentKeys.names.include?(key)
      flash[:error] = "Dieser Einschreibeschlüssel ist unbekannt. Die Groß-/Kleinschreibung zählt."
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
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Deine Daten wurden gelöscht. Beehre uns bald wieder."
    redirect_to users_url
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def chart
    # data for the last 91 days, grouped in 7 days makes 13 buckets
    data = { right: [0]*13, wrong: [0]*13, skipped: [0]*13}

    last_stats = @user.stats.unscoped.where("created_at > ?", 91.days.ago)

    n = Time.now
    last_stats.each do |stat|
      # group by running week
      weeks_ago = (((n - stat.created_at) / 1.day) % 7).to_i
      next if data[:right][weeks_ago].nil?
      data[:skipped][weeks_ago] += 1 if stat.answer_id == -1
      data[:right][weeks_ago] += 1 if stat.answer_id >= 0 && stat.correct
      data[:wrong][weeks_ago] += 1 if stat.answer_id >= 0 && !stat.correct
    end

    percent_correct = []
    percent_skipped = []
    # walk in reverse
    (12.downto(0)).each do |i|
      r = data[:right]
      w = data[:wrong]
      s = data[:skipped]
      rw = r[i] + w[i]
      rws = rw + s[i]
      percent_correct << (rw  == 0 ? -1 : (r[i] / rw.to_f)*100)
      percent_skipped << (rws == 0 ? -1 : (s[i] / rws.to_f)*100)
    end

    @h = LazyHighCharts::HighChart.new('graph', style: '') do |f|
      f.options[:chart][:defaultSeriesType] = "line"
      f.options[:chart][:width] = 600
      f.options[:chart][:height] = 280
      f.options[:tooltip][:enabled] = false
      f.options[:plotOptions][:series] = {pointInterval: 7.days, pointStart: 92.days.ago}
      f.options[:plotOptions][:line] = {animation: false}
      f.series(:name=>'Richtig beantwortete Fragen', :data => percent_correct)
      f.series(:name=>'Übersprungene Fragen', :data => percent_skipped)
      f.xAxis(type: :datetime, dateTimeLabelFormats: { day: '%e. %b' })
      f.yAxis({title: {text: "Anteil in Prozent"}, min: 0, max: 100})
    end
  end
end
