module Deltacloud
  DRIVERS = {
    :ec2 => { :name => "EC2" },
    :rackspace => { :name => "Rackspace" },
    :gogrid => { :name => "Gogrid" },
    :rhevm => { :name => "RHEVM" },
    :rimuhosting => { :name => "RimuHosting"},
    :opennebula => { :name => "Opennebula", :class => "OpennebulaDriver" },
    :terremark => { :name => "Terremark"},
    :azure => { :name => "Azure" },
    :mock => { :name => "Mock" }
  }

  DEFAULT_COLLECTIONS = [
    :hardware_profiles,
    :images,
    :instances,
    :instance_states,
    :realms,
    :storage_volumes,
    :storage_snapshots
  ]

  DRIVER=ENV['API_DRIVER'] ? ENV['API_DRIVER'].to_sym : :mock

  def driver_symbol
    (Thread.current[:driver] || DRIVER).to_sym
  end

  def driver_name
    DRIVERS[:"#{driver_symbol}"][:name]
  end

  def driver_class_name
    basename = DRIVERS[:"#{driver_symbol}"][:class] || "#{driver_name}Driver"
    "Deltacloud::Drivers::#{driver_name}::#{basename}"
  end

  def driver_source_name
    File.join("deltacloud", "drivers", "#{driver_symbol}", "#{driver_symbol}_driver.rb")
  end

  def driver_mock_source_name
    return File.join('deltacloud', 'drivers', "#{driver_symbol}", 
                     "#{driver_symbol}_driver.rb") if driver_name.eql? 'Mock'
  end

  def driver
    require driver_source_name
    #require 'deltacloud/base_driver/mock_driver.rb'

    if Sinatra::Application.environment.eql? :test
      require driver_mock_source_name if driver_mock_source_name
    end

    @driver ||= eval( driver_class_name ).new
  end
end

include Deltacloud
