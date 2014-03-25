#! /usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require "newrelic_plugin"
require "mechanize"
require "socket"

module PmtaAgent

  class Agent < NewRelic::Plugin::Agent::Base

    agent_guid "com.jalalahmad.newrelic.plugin.pmta"
    agent_version "0.0.4"
    agent_config_options :hertz  # frequency of the periodic functions
    agent_human_labels("PowerMTA Agent") { Socket.gethostname }

    ROOT_URL = "http://localhost:8080"
    QUEUE_URL = "/queues?format=xml"
    STATUS_URL = "/status?format=xml"
    DOMAIN_URL = "/domains?format=xml"

    def poll_cycle
      @agent= Mechanize.new unless @agent
      @agent.pluggable_parser['text/html'] = Mechanize::XmlFile
      report_status
      report_queues
      report_domains
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

    def report_queues
      current_queues = queues()
      queues.each do |queue|
        queue_name = "Queues/" + queue.search('name').text()  
        report_metric queue_name + "/Recepients" , "recpts", queue.search('rcp').text() 
        report_metric queue_name + "/KiloBytes" , "kb", queue.search('kb').text()
        report_metric queue_name + "/Connections" , "conns", queue.search('conn').text()
      end
    end

    def report_domains
      current_domains = domains()
      domains.each do |domain|
        domain_name = "Domains/" + domain.search('name').text()  
        report_metric domain_name + "/Recepients" , "recpts", domain.search('rcp').text() 
        report_metric domain_name + "/KiloBytes" , "kb", domain.search('kb').text()
        report_metric domain_name + "/Connections" , "conns", domain.search('conn').text()
      end
    end

    def domains
      response = @agent.get( ROOT_URL + DOMAIN_URL )
      response.search('/rsp/data/domain')
    end

    def queues
      response = @agent.get( ROOT_URL + QUEUE_URL )
      response.search('/rsp/data/queue')
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
