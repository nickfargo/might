## Interest

An **interest** is a specialized `Promise` to a `Potential`. An `Interest` can
be `divest`ed, or “revoked”, by a consumer, causing its associated `Potential`
to disavow all callbacks previously registered via that `Interest`. In addition
a `Potential` is automatically `canceled` once all previously invested
consumers `divest` their `Interest`s in that `Potential`.

    class Interest extends Promise
      noop = ->
      uid = 0

      constructor: ( potential ) ->
        @id = 'interest' + ( uid += 1 )

        @getState = -> potential.state().name

        @once = ( stateName, callback ) ->
          potential._onceInterested this, stateName, callback
          this

        @divest = ->
          @divest = noop
          potential.divest this
          return
