local class = require 'pl.class'
local NetxReset = class()

function NetxReset:_init()
  self.romloader = require 'romloader'

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



function NetxReset:netx_reset(tPlugin, ulResetDelayTicks)
  -- Get the binary for the ASIC.
  local tAsicTyp = tPlugin:GetChiptyp()
  local strBinary = self.astrBinaryName[tAsicTyp]
  if strBinary==nil then
    error('Unknown chiptyp!')
  end
  local strNetxBinary = string.format('netx/netx_reset_netx%s.bin', strBinary)

  local tester = _G.tester
  local atParameter = {
    ulResetDelayTicks,
    0,
    0
  }
  local ulResult = tester:mbin_simple_run(tPlugin, strNetxBinary, atParameter)

end

return NetxReset
