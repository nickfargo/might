    exports = module.exports =
      Potential     : require './potential'
      Interest      : require './interest'
      Cancellation  : require './cancellation'

    exports[k] = v for k,v of require '../../will'
