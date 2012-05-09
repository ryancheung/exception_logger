module ExceptionLogger
  class Engine < ::Rails::Engine
    isolate_namespace ExceptionLogger
  end
end
