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
      uid = 0

      allowed =
        getStateName: yes
        _onceFromInterest: yes
        invest: yes
        divest: yes

      noop = ->

      constructor: ( potential ) ->
        @id = 'interest' + ( uid += 1 )


        @_apply = ( method, args ) ->
          return unless allowed[ method ]
          result = potential[ method ].apply potential, args
          result = this if result is potential
          @_apply = noop if method is 'divest'
          result

      getStateName: ->
        @_apply 'getStateName'

      invest: ->
        @_apply 'invest'

      divest: ->
        @_apply 'divest', [this]

      once: ( stateName, callback ) ->
        @_apply '_onceFromInterest', [ this, stateName, callback ]
