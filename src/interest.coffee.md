    { Promise } = require '../../will'

    module.exports =



## Interest

An **interest** is a specialized `Promise` — a *read-only attenuation* — to a
`Potential`. An `Interest` can be `divest`ed, or “revoked”, by a consumer,
causing its associated `Potential` to disavow all callbacks previously
registered via that `Interest`.

A `Potential` is automatically `canceled` once it and all `Interest`-holding
consumers have `divest`ed themselves of their interest in the `Potential`’s
fate.

    class Interest extends Promise
      noop = ->
      uid = 0

      constructor: ( potential ) ->
        @id = 'interest' + ( uid += 1 )

        @getState = -> potential.state().name

        @once = ( stateName, callback ) ->
          potential._onceFromInterest this, stateName, callback
          this

        @divest = ->
          @divest = noop
          potential.divest this
          return
