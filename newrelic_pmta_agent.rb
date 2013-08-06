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

    def poll_cycle
      
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