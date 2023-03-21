local TestClassNetxReset = require 'test_class_netx_reset'
return function(ulTestID, tLogWriter, strLogLevel)
  return TestClassNetxReset('@NAME@', ulTestID, tLogWriter, strLogLevel)
end
