#! /usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require "newrelic_plugin"
require "mechanize"

module PmtaAgent

  class Agent < NewRelic::Plugin::Agent::Base

    agent_guid "com.jalalahmad.newrelic.plugin.pmta"
    agent_version "0.0.1"
    agent_config_options :hertz  # frequency of the periodic functions
    agent_human_labels("PowerMTA Agent") { "PowerMTA statistics" }

    ROOT_URL = "http://localhost:8080"
    QUEUE_URL = "/queues?format=xml"
    STATUS_URL = "/status?format=xml"

    def poll_cycle
      @agent= Mechanize.new unless @agent
      report_status
    end

    def report_status
      current_status= status()
      report_metric "Status/Messages/In","msgs" , current_status.search('in/msg').text()
      report_metric "Status/Messages/Out" , "msgs", current_status.search('out/msg').text()
      report_metric "Status/Recepients/In" , "recpts",current_status.search('in/rcp').text()
      report_metric "Status/Recepients/Out" , "recpts", current_status.search('out/rcp').text()
      report_metric "Status/KiloBytes/In" , "kb", current_status.search('in/kb').text()
      report_metric "Status/KiloBytes/Out" , "kb", current_status.search('out/kb').text()
    end
    def queues
      response = @agent.get( ROOT_URL + QUEUE_URL )

    end
    def status
      response = @agent.get( ROOT_URL + STATUS_URL )
      response.search('/rsp/data/status/traffic/lastMin')
    end

  end

  #
  # Register this agent with the component.
  # The PmtaAgent is the name of the module that defines this
  # driver (the module must contain at least three classes - a
  # PollCycle, a Metric and an Agent class, as defined above).
  #
  NewRelic::Plugin::Setup.install_agent :pmta, PmtaAgent

  #
  # Launch the agent; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run

end
