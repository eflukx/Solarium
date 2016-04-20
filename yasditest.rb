#!/usr/bin/ruby
require 'ffi'
require './ffi-yasdi'
require 'pry'


class FFI::MemoryPointer
  def length
    size/type_size
  end
end

module Yasdi

  class InvalidDeviceHandle < Exception

  end

  class Version < Struct.new("Version", :major, :minor, :release, :build)
    def initialize
      vptr = FFI::MemoryPointer.new(:uint8, 4)
      YasdiMaster.yasdiMasterGetVersion(vptr[0], vptr[1], vptr[2], vptr[3])
      super *vptr.read_array_of_uint8(4)
    end

    def to_s
      values.join '.'
    end
  end

  class Driver

  end

  class Device
    def initialize handle
      @handle = handle
    end
  end

  class Channel
    def initialize handle
      @handle = handle
    end
  end


#Needs to be called once for YASDI init. It'll evaluate the config file and setup the system.
  def init()
    driver_count = FFI::MemoryPointer.new(:uint32)

    YasdiMaster.yasdiMasterInitialize("/etc/yasdi.ini", driver_count)

    puts "Found drivers: #{drivers}"
    set_all_drivers_online
    puts "detecting devices"
    detect_devices_sync 1
    handles = get_device_handles

    dh = handles.first

    puts get_device_type dh
    puts get_device_sn dh

    puts "Getting all channels"
    p get_channel_handles(dh).map{|ch| get_channel_value ch,1,0}
    p get_channel_handles(dh, 0x90f).map{|ch| get_channel_value ch,1,0}

    binding.pry
    # return driver_count.get_uint32(0)
  end

#Needs to be called when exiting
  def shutdown()
    YasdiMaster.yasdiMasterShutdown
  end

  def reset()
    YasdiMaster.yasdiReset
  end

#returns YASDI library version :major, :minor, :release, :build in a Hashtable
  def version
    @ver ||= Yasdi::Version.new
  end

  def get_device_sn handle
    ptr = FFI::MemoryPointer.new(:uint32) # SN is only one dword (?) according to manual
    ret = YasdiMaster.GetDeviceSN(handle, ptr)
    ptr.read_uint32 if ret == 0
  end

  def get_device_type handle
    ptr = FFI::MemoryPointer.new(:char, 8)
    ret = YasdiMaster.GetDeviceType(handle, ptr, ptr.size)
    raise Yasdi::InvalidDeviceHandle if ret != 0
    ptr.read_string
  end

  def drivers
    get_driver_ids.inject({}) { |h, i| h[i]= get_driver_name(i); h }
  end

  def get_driver_ids max_drv = 16
    drv_ary = FFI::MemoryPointer.new(:uint32, max_drv)
    len = YasdiMaster.yasdiMasterGetDriver drv_ary, drv_ary.length
    drv_ary.read_array_of_uint32 len
  end

  def get_driver_name drv_id
    name_ptr = FFI::MemoryPointer.new(:char, 64)
    exists = YasdiMaster.yasdiMasterGetDriverName drv_id, name_ptr, name_ptr.size
    name_ptr.read_string if exists
  end

  def set_all_drivers_online
    get_driver_ids.map { |id| YasdiMaster.yasdiMasterSetDriverOnline id }
  end

#returns the number of detected devices
  def detect_devices(max_devices = 1)
    return YasdiMaster.DoStartDeviceDetection(max_devices, false)
  end

  def detect_devices_sync(max_devices = 1)
    return YasdiMaster.DoStartDeviceDetection(max_devices, true)
    # -1 =   YE_NOT_ALL_DEVS_FOUND
    # 0 = OK
  end

  def get_device_handles(max_devices = 64)
    handles_ptr = FFI::MemoryPointer.new(:uint32, max_devices)
    len = YasdiMaster.GetDeviceHandles(handles_ptr, handles_ptr.length)

    handles_ptr.read_array_of_uint32(len)
  end

  def get_device_name handle
    device_name = FFI::MemoryPointer.new(:char, 80)
    len = YasdiMaster.GetDeviceName(handle, device_name, device_name.size)
    device_name.read_string(len) if len >= 0
  end

  def get_devices
    get_device_handles.map { |dh| Yasdi::Device.new(dh) }
  end

  def get_drivers(max_drivers = 64)
    ptr = FFI::MemoryPointer.new(:uint32, max_drivers)
    len = YasdiMaster.yasdiMasterGetDriver(ptr, ptr.length)
    ptr.read_array_of_uint32(len)
  end

  def get_channel_handles dev_handle, chan_type = 0x40f, chan_index = 0
    # 0x40f params channels
    # 0x90f spot channels

    ptr = FFI::MemoryPointer.new(:uint32, 128)
    len = YasdiMaster.GetChannelHandles(dev_handle, ptr, ptr.length, chan_type, chan_index)
    ptr.read_array_of_uint32(len)
  end

  def get_channel_name handle
    ptr = FFI::MemoryPointer.new(:char, 80)
    len = YasdiMaster.GetChannelName(handle, ptr, ptr.size)
    puts len
    ptr.read_string(len) if len >= 0
  end

# #int GetChannelValue(DWORD dChannelHandle, DWORD dDeviceHandle, double * dblValue, char * ValText, DWORD dMaxValTextSize, DWORD dMaxChanValAge)
#   attach_function :GetChannelValue, [:uint, :uint, :pointer, :string, :uint, :uint], :int

  def get_channel_value ch_handle, dev_handle, max_age
    # 0 ==> Everything OK: channel value is valid...
    #                                           -1 ==> Error: channel handle was invalid...
    #                                                                                -2 ==> Error: YASDI driver is in the "ShutDown" state
    # -3 ==> Error: timeout during new retrieval of channel value
    # -4 ==> Error: unknown error; channel value invalid

    txt_ptr = FFI::MemoryPointer.new(:char, 80)
    val_ptr = FFI::MemoryPointer.new(:double)
    YasdiMaster.GetChannelValue(ch_handle, dev_handle, val_ptr, txt_ptr, txt_ptr.size, max_age)


    value = val_ptr.read_double
    txt = txt_ptr.read_string

    {txt => value}
  end

  def get_channels
    get_channel_handles.map { |ch| Yasdi::Channel.new ch }
  end

  def channels dev_handle
    get_channel_handles(dev_handle).inject({}) { |h, i| h[i]= get_channel_name(i); h }
  end

  extend self

end


print "Initing YASDI. Found " + Yasdi.init().to_s + " driver(s).\n"

puts Yasdi.version
#puts version.values.join('.')

puts "setting driver online"
#yasdiMasterSetDriverOnline( i );

puts "detect devs \n result:"
puts Yasdi.detect_devices_sync

puts "get handles \n result:"
puts Yasdi.get_device_handles

Yasdi.reset
Yasdi.shutdown