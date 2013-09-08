#!/usr/bin/ruby
require 'ffi'
require './ffi-yasdi'

  #Needs to be called once for YASDI init. It'll evaluate the config file and setup the system.
  def yasdi_init()
    driver_count = FFI::MemoryPointer.new(:uint32)
    YasdiMaster.yasdiMasterInitialize("/etc/yasdi.ini", driver_count)
    return driver_count.get_uint(0)  
  end

  #Needs to be called when exiting
  def shutdown()
    YasdiMaster.yasdiMasterShutdown
  end

  def reset()
    YasdiMaster.yasdiReset
  end

  #returns YASDI library version :major, :minor, :release, :build in a Hashtable
  def version()
    _versionpointer = FFI::MemoryPointer.new(:uint32)
    _version = {}

    YasdiMaster.yasdiMasterGetVersion(_versionpointer + 0, _versionpointer + 1, _versionpointer + 2, _versionpointer + 3)
    [:major, :minor, :release, :build].zip((0..3).to_a).each {|id, offset| _version[id]=_versionpointer.get_char(offset)}
    
    return _version
  end

  #returns the number of detected devices
  def detect_devices
    max_devices = 1
    return YasdiMaster.DoStartDeviceDetection(max_devices, false)
  end
  
  def get_device_handles
    max_devices = 1
    device_handles = FFI::MemoryPointer.new(:uint32, max_devices)
    YasdiMaster.GetDeviceHandles(device_handles, max_devices)
    return device_handles.get_uint(0)
  end
  
  def get_device_name(handle)
    device_name = FFI::MemoryPointer.new(:char, 80)
    len = YasdiMaster.GetDeviceName(handle, device_name, device_name.size)
    return device_name.read_string(len) 
  end
  
print "Initing YASDI. Found " + yasdi_init().to_s + " driver(s).\n"

puts version
#puts version.values.join('.')

puts "detect devs \n result:"
puts detect_devices

puts "get handles \n result:"
puts get_device_handles

reset
shutdown