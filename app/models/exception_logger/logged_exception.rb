module ExceptionLogger
  class LoggedException < ActiveRecord::Base
    self.table_name = "logged_exceptions"
    HOSTNAME = `hostname -s`.chomp
    class << self
      def create_from_exception(controller, exception, data)
        message = exception.message.inspect
        message << "\n* Extra Data\n\n#{data}" unless data.blank?
        e = create! \
          :exception_class => exception.class.name,
          :controller_name => controller.controller_path,
          :action_name     => controller.action_name,
          :message         => message,
          :backtrace       => exception.backtrace,
          :request         => controller.request
      end

      def host_name
        HOSTNAME
      end
    end

    scope :by_exception_class, lambda {|exception_class| where(:exception_class => exception_class)}
    scope :by_controller_and_action, lambda {|controller_name, action_name| where(:controller_name => controller_name, :action_name => action_name)}
    scope :by_controller, lambda {|controller_name| where(:controller_name => controller_name)}
    scope :by_action, lambda {|action_name| where(:action_name => action_name)}
    scope :message_like, lambda {|query|  where('message like ?', "%#{query}%")}
    scope :days_old, lambda {|day_number| where('created_at >= ?', day_number.to_f.days.ago.utc)}
    scope :sorted, lambda { order('created_at DESC') }

    def name
      "#{self.exception_class} in #{self.controller_action}"
    end

    def backtrace=(trace)
      trace = sanitize_backtrace(trace) * "\n" unless trace.is_a?(String)
      write_attribute :backtrace, trace
    end

    def request=(request)
      if request.is_a?(String)
        write_attribute :request, request
      else
        max = request.env.keys.max { |a,b| a.length <=> b.length }
        env = request.env.keys.sort.inject [] do |env, key|
          env << '* ' + ("%-*s: %s" % [max.length, key, request.env[key].to_s.strip])
        end
        write_attribute(:environment, (env << "* Process: #{$$}" << "* Server : #{self.class.host_name}") * "\n")

        write_attribute(:request, [
            "* URL:#{" #{request.method.to_s.upcase}" unless request.get?} #{request.protocol}#{request.env["HTTP_HOST"]}#{request.fullpath}",
            "* Format: #{request.format.to_s}",
            "* Parameters: #{request.parameters.inspect}",
            "* Rails Root: #{rails_root}"
          ] * "\n")
      end
    end

    def controller_action
      @controller_action ||= "#{controller_name.camelcase}/#{action_name}"
    end

    def self.class_names
      select("DISTINCT exception_class").order(:exception_class).collect(&:exception_class)
    end

    def self.controller_actions
      select("DISTINCT controller_name, action_name").order(:controller_name,:action_name).collect(&:controller_action)
    end

    private
    @@rails_root      = Pathname.new(Rails.root).cleanpath.to_s
    @@backtrace_regex = /^#{Regexp.escape(@@rails_root)}/

    def sanitize_backtrace(trace)
      trace.collect { |line| Pathname.new(line.gsub(@@backtrace_regex, "[RAILS_ROOT]")).cleanpath.to_s }
    end

    def rails_root
      @@rails_root
    end
  end
end
