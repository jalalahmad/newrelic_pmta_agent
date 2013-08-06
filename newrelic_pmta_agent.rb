#! /usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require "newrelic_plugin"

module PmtaAgent

  class Agent < NewRelic::Plugin::Agent::Base

    agent_guid "com.jalalahmad.newrelic.plugin.pmta"
    agent_version "0.0.1"
    agent_config_options :hertz  # frequency of the periodic functions
    agent_human_labels("PowerMTA Agent") { "PowerMTA statistics" }

    ROOT_URL = :SERVER_ROOT || "http://localhost:8080"
    QUEUE_URL = "/queues?format=xml"
    STATUS_URL = "/status?format=xml"
    @agent = Mechanize.new


    def poll_cycle
      stats = status
      report_metric "Component/Status/Messages/In[msgs]" , stats.in.msg.text()
      report_metric "Component/Status/Messages/Out[msgs]" , stats.out.msg.text()
      report_metric "Component/Status/Recepients/In[rcpts]" , stats.in.rcp.text()
      report_metric "Component/Status/Recepients/Out[rcpts]" , stats.out.rcp.text()
      report_metric "Component/Status/Bytes/In[kb]" , stats.in.kb.text()
      report_metric "Component/Status/Bytes/Out[kb]" , stats.out.kb.text()
    end

    def queues
      response = @agent.get ROOT_URL + QUEUE_URL

    end
    def status
      response = @agent.get ROOT_URL + STATUS_URL
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