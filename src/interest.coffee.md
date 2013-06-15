    { Promise } = require '../../will'

    module.exports =



## Interest

An **interest** is a specialized `Promise` to a `Potential`. An `Interest` can
be `divest`ed, or “revoked”, by a consumer, causing its associated `Potential`
to disavow all callbacks previously registered via that `Interest`.

A `Potential` is automatically `canceled` once all previously `invest`ed
consumers, as well as the `Potential` itself, have `divest`ed themselves.

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
