module ExceptionLogger
  module LoggedExceptionsHelper
    def pretty_exception_date(exception)
      if Date.today == exception.created_at.to_date
        if false # exception.created_at > Time.now - 4.hours
          "#{time_ago_in_words(exception.created_at).gsub(/about /,"~ ")} agox"
        else
          "Today, #{exception.created_at.strftime(Time::DATE_FORMATS[:exc_time])}"
        end
      else
        exception.created_at.strftime(Time::DATE_FORMATS[:exc_date])
      end
    end

    def filtered?
      [:query, :date_ranges_filter, :exception_names_filter, :controller_actions_filter].any? { |p| params[p] }
    end

    def listify(text)
      list_items = text.scan(/^\s*\* (.+)/).map {|match| content_tag(:li, match.first) }
      content_tag(:ul, list_items)
    end

    def page_title(text)
      title = ""
      unless controller.application_name.blank?
        title << "#{controller.application_name} :: "
      end
      title << text.to_s
      content_for(:title, title.to_s)
    end

    # Rescue textilize call if RedCloth is not available.
    def pretty_format(text)
      begin
        textilize(text).html_safe
      rescue
        simple_format(text).html_safe
      end
    end
  end
end
