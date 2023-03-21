local class = require 'pl.class'
local TestClass = require 'test_class'
local TestClassNetxReset = class(TestClass)

function TestClassNetxReset:_init(strTestName, uiTestCase, tLogWriter, strLogLevel)
  self:super(strTestName, uiTestCase, tLogWriter, strLogLevel)

  local P = self.P
  self:__parameter {
    P:P('plugin', 'A pattern for the plugin to use.'):
      required(false),

    P:P('plugin_options', 'Plugin options as a JSON object.'):
      required(false),

    P:U32('reset_delay', 'Delay of the reset in 10ns ticks.'):
      default(50000000):
      required(true),

    P:U32('reconnect_delay', 'Delay of the reconnect attempts in 1ms ticks.'):
      default(2000):
      required(true),

    P:U32('reconnect_retries', 'Number of reconnect retries.'):
      default(4):
      required(true)

--    P:P('option_file', 'Option file to determine the startup behaviour of the netX.'):
--      required(true),
  }
end



function TestClassNetxReset:run()
  local atParameter = self.atParameter
  local tLog = self.tLog
  local pl = self.pl

  ----------------------------------------------------------------------
  --
  -- Parse the parameters and collect all options.
  --
  local strPluginPattern = atParameter['plugin']:get()
  local strPluginOptions = atParameter['plugin_options']:get()

  local ulResetDelayTicks = atParameter['reset_delay']:get()
  local ulReconnectDelayTicks = atParameter['reconnect_delay']:get()
  local ulReconnectRetries = atParameter['reconnect_retries']:get()

--  local strOptionFile = atParameter['option_file']:get()

  ----------------------------------------------------------------------
  --
  -- Open the connection to the netX.
  -- (or re-use an existing connection.)
  --
  local json = require 'dkjson'
  local atPluginOptions = {}
  if strPluginOptions~=nil then
    local tJson, uiPos, strJsonErr = json.decode(strPluginOptions)
    if tJson==nil then
      tLog.warning('Ignoring invalid plugin options. Error parsing the JSON: %d %s', uiPos, strJsonErr)
    else
      atPluginOptions = tJson
    end
  end
  local tPlugin = _G.tester:getCommonPlugin(strPluginPattern, atPluginOptions)
  if tPlugin==nil then
    local strPluginOptionsPretty = pl.pretty.write(atPluginOptions)
    local strError = string.format(
      'Failed to establish a connection to the netX with pattern "%s" and options "%s".',
      strPluginPattern,
      strPluginOptionsPretty
    )
    error(strError)
  end

  local tNetxReset = require 'netx_reset'()
--  tNetxReset:download_options(tPlugin, strOptionFile)
  tNetxReset:netx_reset(tPlugin, ulResetDelayTicks)

  -- Close the plugin.
  _G.tester:closeCommonPlugin()
  tPlugin = nil
  collectgarbage('collect');

  local socket = require 'socket'
  local ulRetries = 0
  repeat
    -- Delay a while and re-open the plugin.
    socket.sleep(ulReconnectDelayTicks / 1000)

    tPlugin = _G.tester:getCommonPlugin(strPluginPattern, atPluginOptions)
    if tPlugin==nil then
      local strPluginOptionsPretty = pl.pretty.write(atPluginOptions)
      local strError = string.format(
        'Failed to re-open the connection to the netX with pattern "%s" and options "%s".',
        strPluginPattern,
        strPluginOptionsPretty
      )

      ulRetries = ulRetries + 1
      if ulRetries>ulReconnectRetries then
        tLog.error('Failed to connect and no more retries left: %s', strError)
        error(strError)
      else
        tLog.error('Failed to connect: %s', strError)
      end
    end
  until tPlugin~=nil

  print("")
  print(" #######  ##    ## ")
  print("##     ## ##   ##  ")
  print("##     ## ##  ##   ")
  print("##     ## #####    ")
  print("##     ## ##  ##   ")
  print("##     ## ##   ##  ")
  print(" #######  ##    ## ")
  print("")
end


return TestClassNetxReset
