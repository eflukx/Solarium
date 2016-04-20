module YasdiMaster
  extend FFI::Library
  ffi_lib ["libyasdimaster", "yasdimaster"]
  
  ################################################################################
  ## YASDI general functions
  ################################################################################
  #int yasdiMasterGetVersion( BYTE * major, BYTE * minor, BYTE * release, BYTE * build)
  attach_function :yasdiMasterGetVersion, [:pointer, :pointer, :pointer, :pointer], :int
  
  #void yasdiMasterInitialize( char * cIniFileName, DWORD * pDriverCount) 
  attach_function :yasdiMasterInitialize, [:string, :pointer], :void

  #void yasdiMasterShutdown( void );
  attach_function :yasdiMasterShutdown, [], :void

  #void yasdiReset( void )
  attach_function :yasdiReset, [], :void
  
  ################################################################################
  ## Bus driver functions
  ################################################################################
  #DWORD yasdiMasterGetDriver(DWORD * DriverHandleArray, int maxHandles);
  attach_function :yasdiMasterGetDriver, [:pointer, :uint], :uint
  
  #BOOL yasdiMasterSetDriverOnline(DWORD DriverID);
  attach_function :yasdiMasterSetDriverOnline, [:uint], :bool
  
  #void yasdiMasterSetDriverOffline(DWORD DriverID);
  attach_function :yasdiMasterSetDriverOffline, [:uint], :void
  
  #BOOL yasdiMasterGetDriverName(DWORD DriverID, char * DestBuffer, DWORD MaxBufferSize);
  attach_function :yasdiMasterGetDriverName, [:uint, :pointer, :uint], :bool
  
  ################################################################################
  ## Device functions
  ################################################################################
  #int DoStartDeviceDetection(int iCountDevsToBePresent, BOOL bWaitForDone);
  attach_function :DoStartDeviceDetection, [:int, :bool], :int
  
  #int DoStopDeviceDetection(void);
  attach_function :DoStopDeviceDetection, [], :int
  
  #DWORD GetDeviceHandles(DWORD * Handles, DWORD iHandleCount)
  attach_function :GetDeviceHandles, [:pointer, :uint], :uint

  #int GetDeviceName( DWORD DevHandle, char * DestBuffer, int len)
  attach_function :GetDeviceName, [:uint, :pointer, :int], :int

  #int GetDeviceSN( DWORD DevHandle, DWORD * SNBuffer );
  attach_function :GetDeviceSN, [:uint, :pointer], :int

  #int GetDeviceType(DWORD DevHandle, char * DestBuffer, int len) 
  attach_function :GetDeviceType, [:uint, :pointer, :int], :int

  ################################################################################
  ## Channel functions
  ################################################################################
  #DWORD GetChannelHandles(DWORD pdDevHandle, DWORD * pdChanHandles, DWORD dMaxHandleCount, WORD wChanType, BYTE bChanIndex)
  attach_function :GetChannelHandles, [:uint, :pointer, :uint, :uint16, :uchar], :uint

  # DWORD FindChannelName(DWORD pdDevHandle, char * ChanName);
  attach_function :FindChannelName, [:uint, :pointer], :uint
 
  #int GetChannelName( DWORD dChanHandle, char * ChanName, DWORD ChanNameMaxBuf);
  attach_function :GetChannelName, [:uint, :pointer, :uint], :int

  #int GetChannelValue(DWORD dChannelHandle, DWORD dDeviceHandle, double * dblValue, char * ValText, DWORD dMaxValTextSize, DWORD dMaxChanValAge)
  attach_function :GetChannelValue, [:uint, :uint, :pointer, :pointer, :uint, :uint], :int

  #DWORD GetChannelValueTimeStamp( DWORD dChannelHandle )
  attach_function :GetChannelValueTimeStamp, [:uint], :uint

  #int GetChannelUnit( DWORD dChannelHandle, char * cChanUnit, DWORD cChanUnitMaxSize)
  attach_function :GetChannelUnit, [:uint, :pointer, :uint], :int

  #int GetMasterStateIndex() 
  attach_function :GetMasterStateIndex, [], :int

  #int SetChannelValue(DWORD dChannelHandle, DWORD dDevHandle, double dblValue).
  attach_function :SetChannelValue, [:uint, :uint, :double], :int
  
  #int SetChannelValueString(DWORD dChannelHandle, DWORD dDevHandle, const char * chanvalstr )
  attach_function :SetChannelValueString, [:uint, :uint, :string], :int

  #int GetChannelStatTextCnt(DWORD dChannelHandle)
  attach_function :GetChannelStatTextCnt, [:uint], :int

  #int GetChannelStatText(DWORD dChannelHandle, int iStatTextIndex, char * TextBuffer, int BufferSize)
  attach_function :GetChannelStatText, [:uint, :int, :pointer, :int], :int

  #int GetChannelMask( DWORD dChannelHandle, WORD * ChanType, int * ChanIndex)
  attach_function :GetChannelMask, [:uint, :pointer, :pointer], :int
end