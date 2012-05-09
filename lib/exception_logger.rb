require "exception_logger/engine"
require "will_paginate"
require 'ipaddr'

module ExceptionLogger
  # Copyright (c) 2005 Jamis Buck
  #
  # Permission is hereby granted, free of charge, to any person obtaining
  # a copy of this software and associated documentation files (the
  # "Software"), to deal in the Software without restriction, including
  # without limitation the rights to use, copy, modify, merge, publish,
  # distribute, sublicense, and/or sell copies of the Software, and to
  # permit persons to whom the Software is furnished to do so, subject to
  # the following conditions:
  #
  # The above copyright notice and this permission notice shall be
  # included in all copies or substantial portions of the Software.
  #
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  module ExceptionLoggable
    def self.included(target)
      target.extend(ClassMethods)
      target.class_attribute :local_addresses, :exception_data

      target.local_addresses = [IPAddr.new("127.0.0.1")]
    end

    module ClassMethods
      def consider_local(*args)
        local_addresses.concat(args.flatten.map { |a| IPAddr.new(a) })
      end
    end

    def local_request?
      remote = IPAddr.new(request.remote_ip)
      !self.class.local_addresses.detect { |addr| addr.include?(remote) }.nil?
    end

    # we log the exception and raise it again, for the normal handling.
    def log_exception_handler(exception)
      log_exception(exception)
      raise exception
    end

    def rescue_action(exception)
      status = response_code_for_rescue(exception)
      log_exception(exception) if status != :not_found
      super
    end

    def log_exception(exception)
      deliverer = self.class.exception_data
      data = case deliverer
      when nil    then {}
      when Symbol then send(deliverer)
      when Proc   then deliverer.call(self)
      end

      LoggedException.create_from_exception(self, exception, data)
    end
  end
end
