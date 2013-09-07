#!/usr/bin/ruby
require 'ffi'

module Yasdi
  extend FFI::Library
  ffi_lib "libyasdimaster"

  #void yasdiMasterInitialize( char * cIniFileName, DWORD * pDriverCount) 
  attach_function :yasdiMasterInitialize, [:string, :pointer], :void

  #void yasdiMasterShutdown( void );
  attach_function :yasdiMasterShutdown, [:void], :void

  #void yasdiReset( void )
  attach_function :yasdiReset, [:void], :void

  #DWORD GetDeviceHandles(DWORD * Handles, DWORD iHandleCount)
  attach_function :GetDeviceHandles, [:pointer, :uint], :uint

  #int GetDeviceName( DWORD DevHandle, char * DestBuffer, int len)
  attach_function :GetDeviceName, [:uint, :pointer, :int], :int

  #int GetDeviceSN( DWORD DevHandle, DWORD * SNBuffer );
  attach_function :GetDeviceSN, [:uint, :pointer], :int

  #int GetDeviceType(DWORD DevHandle, char * DestBuffer, int len) 
  attach_function :GetDeviceType, [:uint, :pointer, :int], :int

  #DWORD GetChannelHandles(DWORD pdDevHandle, DWORD * pdChanHandles, DWORD dMaxHandleCount, WORD wChanType, BYTE bChanIndex)
  attach_function :GetChannelHandles, [:uint, :pointer, :uint, :int, :short, :uchar], :uint

  #int GetChannelName( DWORD dChanHandle, char * ChanName, DWORD ChanNameMaxBuf);
  attach_function :GetChannelName, [:uint, :string, :uint], :int

  #int GetChannelValue(DWORD dChannelHandle, DWORD dDeviceHandle, double * dblValue, char * ValText, DWORD dMaxValTextSize, DWORD dMaxChanValAge)
  attach_function :GetChannelValue, [:uint, :uint, :pointer, :string, :uint, :uint], :int

  #DWORD GetChannelValueTimeStamp( DWORD dChannelHandle )
  attach_function :GetChannelValueTimeStamp, [:uint], :uint

  #int GetChannelUnit( DWORD dChannelHandle, char * cChanUnit, DWORD cChanUnitMaxSize)
  attach_function :GetChannelUnit, [:uint, :pointer, :uint], :int

  #int GetMasterStateIndex() 
  attach_function :GetMasterStateIndex, [], :int

  #int SetChannelValue(DWORD dChannelHandle, DWORD dDevHandle, double dblValue).
  attach_function :SetChannelValue, [:uint, :uint, :double], :int

  #int GetChannelStatTextCnt(DWORD dChannelHandle)
  attach_function :GetChannelStatTextCnt, [:uint], :int

  #int GetChannelStatText(DWORD dChannelHandle, int iStatTextIndex, char * TextBuffer, int BufferSize)
  attach_function :GetChannelStatText, [:uint, :int, :pointer, :int], :int

  #int GetChannelMask( DWORD dChannelHandle, WORD * ChanType, int * ChanIndex)
  attach_function :GetChannelMask, [:uint, :pointer, :pointer], :int

  #int DoMasterCmdEx(char * cmd, DWORD Param1, DWORD Param2, DWORD Param3)
#   attach_function :DoMasterCmdEx, [:string, :int, :int, :int], :int

end

DriverCount  = FFI::MemoryPointer.new(:int, 1)
#puts DriverCount.get_uint16(0)
Yasdi.yasdiMasterInitialize("/estc/yasdi.ini", DriverCount)
