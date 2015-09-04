class CreateExceptionLoggerLoggedExceptions < ActiveRecord::Migration
  def change
    create_table :exception_logger_logged_exceptions do |t|
      t.string :exception_name
      t.text :exception_message
      t.string :controller_name
      t.string :action_name
      t.string :sid
      t.text :params
      t.text :url
      t.text :session_data
      t.text :stack_trace
      t.datetime :created_at
      t.datetime :updated_at      
    end
  end
end