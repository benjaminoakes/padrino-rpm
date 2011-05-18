puts "Warning! The padrino-rpm gem should be loaded before the newrelic_rpm gem." if defined?(::NewRelic) && defined?(::NewRelic::Control)

module NewRelic #:nodoc:
  class LocalEnvironment #:nodoc:
    module Padrino
      def discover_framework
        if defined?(::Padrino)
          @framework = 'padrino'
        else
          super
        end
      end
    end
  end
end

module PadrinoRpm
  def self.init!
    NewRelic::Agent.add_instrumentation(
      File.join(
        File.dirname(__FILE__),
        'padrino-rpm/instrumentation/**/*.rb'
      )
    )
    
    require "ext/metric_parser"
  end
end

Padrino.after_load do
  PadrinoRpm.init!
end

Padrino.before_load do
  require 'new_relic/rack_app'

  if Padrino.env == :development
    Padrino.use NewRelic::Rack::DeveloperMode
  end
end

