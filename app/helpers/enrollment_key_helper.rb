# encoding: utf-8

module EnrollmentKeyHelper
  def valid_enrollment_key?(key)
    EnrollmentKeys.names.include?(key)
  end

  def require_valid_enrollment_key
    key = @key || params[:enrollment_key]
    return if valid_enrollment_key?(key)

    flash[:error] = "Einschreibeschlüssel „#{key}“ ist unbekannt. Die Groß-/Kleinschreibung zählt."

    path = if admin?
      admin_overview_path
    elsif signed_in?
      edit_user_path(current_user)
    else
      main_overview_path
    end

    redirect_to path
  end
end
