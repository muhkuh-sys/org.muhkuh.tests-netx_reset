local class = require 'pl.class'
local NetxReset = class()

function NetxReset:_init()
  local romloader = require 'romloader'
  self.astrBinaryName = {
--    [romloader.ROMLOADER_CHIPTYP_NETX4000_RELAXED] = '4000',
--    [romloader.ROMLOADER_CHIPTYP_NETX4000_FULL]    = '4000',
--    [romloader.ROMLOADER_CHIPTYP_NETX4100_SMALL]   = '4000',
--    [romloader.ROMLOADER_CHIPTYP_NETX500]          = '500',
--    [romloader.ROMLOADER_CHIPTYP_NETX100]          = '500',
--    [romloader.ROMLOADER_CHIPTYP_NETX90_MPW]       = '90_mpw',
    [romloader.ROMLOADER_CHIPTYP_NETX90]           = '90',
    [romloader.ROMLOADER_CHIPTYP_NETX90B]          = '90',
--    [romloader.ROMLOADER_CHIPTYP_NETX56]           = '56',
--    [romloader.ROMLOADER_CHIPTYP_NETX56B]          = '56',
--    [romloader.ROMLOADER_CHIPTYP_NETX50]           = '50',
--    [romloader.ROMLOADER_CHIPTYP_NETX10]           = '10'
--    [romloader.ROMLOADER_CHIPTYP_NETIOLA]          = 'IOL',
--    [romloader.ROMLOADER_CHIPTYP_NETIOLB]          = 'IOL'
  }
end


function NetxReset:download_options(tPlugin, strOptionFile)
  -- Get the buffer for the option file.
  local tAsicTyp = tPlugin:GetChiptyp()
  local ulBuffer = self.aulOptionBuffer[tAsicTyp]
  if ulBuffer==nil then
    error('Unsupported chip type.')
  end

  -- Load the option file.
  local strOptionData, strOptionReadError = self.pl.utils.readfile(strOptionFile, true)
  if strOptionData==nil then
    error('Failed to read the option file "'..tostring(strOptionFile)..'": '..tostring(strOptionReadError))
  end

  -- Download the options.
  _G.tester:stdWrite(tPlugin, ulBuffer, strOptionData)
end



function NetxReset:netx_reset(tPlugin, ulResetDelayTicks, strOptionFile)
  local tLog = self.tLog

  -- Get the binary for the ASIC.
  local tAsicTyp = tPlugin:GetChiptyp()
  local strBinary = self.astrBinaryName[tAsicTyp]
  if strBinary==nil then
    error('Unknown chiptyp!')
  end
  local strNetxBinary = string.format('netx/netx_reset_netx%s.bin', strBinary)

  local tester = _G.tester
  local aAttr = tester:mbin_open(strNetxBinary, tPlugin)
  tester:mbin_debug(aAttr)

  -- Read the option file, if one was specified.
  local ulOptionAddress = 0
  local ulOptionSize = 0
  if strOptionFile~=nil then
    local utils = require 'pl.utils'
    local strOptionData, strOptionReadError = utils.readfile(strOptionFile, true)
    if strOptionData==nil then
      local strMsg = string.format(
        'Failed to read the option file "%s": %s',
        tostring(strOptionFile),
        tostring(strOptionReadError)
      )
      tLog.error(strMsg)
      error(strMsg)
    end

    -- Download the option data.
    ulOptionAddress = aAttr.ulParameterStartAddress + 0x20
    ulOptionSize = string.len(strOptionData)
    tester:stdWrite(tPlugin, ulOptionAddress, strOptionData)
  end

  local atParameter = {
    ulResetDelayTicks,
    ulOptionAddress,
    ulOptionSize
  }
  tester:mbin_write(tPlugin, aAttr)
  tester:mbin_set_parameter(tPlugin, aAttr, atParameter)
  local ulResult = tester:mbin_execute(tPlugin, aAttr, atParameter)
  if ulResult~=0 then
    local strMsg = string.format('Failed to queue a reset on the netX board: 0x%08x.', ulResult)
    tLog.error(strMsg)
    error(strMsg)
  end
end

return NetxReset
