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
  tNetxReset:netx_reset(tPlugin)

  -- Close the plugin.
  _G.tester:closeCommonPlugin()
  tPlugin = nil
--[[
  -- Delay a while and re-open the plugin.
  os.execute('sleep 3')
  tPlugin = _G.tester:getCommonPlugin(strPluginPattern, atPluginOptions)
  if tPlugin==nil then
    local strPluginOptionsPretty = pl.pretty.write(atPluginOptions)
    local strError = string.format(
      'Failed to re-open the connection to the netX with pattern "%s" and options "%s".',
      strPluginPattern,
      strPluginOptionsPretty
    )
    error(strError)
  end
--]]
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
