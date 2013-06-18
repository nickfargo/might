    { Promise } = require 'will'

    module.exports =



## Interest

An **interest** is a specialized `Promise` — a *read-only attenuation* — to a
`Potential`. Callbacks registered through an `Interest` are valid so long as
the `Interest` remains *vested*.

A consumer acquires an `Interest` by `invest`ing in a `Potential` directly, or
indirectly via an existing vested `Interest`. The consumer may later `divest`
an `Interest` to which it holds a reference, causing its associated `Potential`
to disavow all callbacks previously registered via that `Interest`.

A `Potential` is automatically `canceled` once it and all `Interest`-holding
consumers have `divest`ed themselves of their interest in the fate of the
`Potential`’s resolution.

    class Interest extends Promise
      uid = 0

      allowed =
        getStateName: yes
        _onceFromInterest: yes
        invest: yes
        divest: yes

      noop = ->


### Constructor

      constructor: ( potential ) ->
        @id = 'interest' + ( uid += 1 )


#### apply

Delegates approved method calls to the enclosed `potential`. Calling `divest`
discards the closure holding `potential`, after which all subsequent method
calls will return `undefined`.

        @_apply = ( method, args ) ->
          return unless allowed[ method ]
          result = potential[ method ].apply potential, args
          result = this if result is potential
          @_apply = noop if method is 'divest'
          result



### Methods

      getStateName: ->
        @_apply 'getStateName'

      invest: ->
        @_apply 'invest'

      divest: ->
        @_apply 'divest', [this]

      once: ( stateName, callback ) ->
        @_apply '_onceFromInterest', [ this, stateName, callback ]
