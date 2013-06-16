    { Deferral, state } = require '../../will'

    Interest = require './interest'

    { isArray } = require 'util'

    module.exports =



## Potential

A **potential** is a vested, disposable, auto-cancelling **future**.

`Potential` is a type of `Deferral` that issues `Interest`s, an extension of
`Promise`s, to consumers who `invest` in the `Potential` to express their
interest in its eventual resolution. As with a `Promise` to a `Deferral`, an
`invest`ed consumer may use its acquired `Interest` to observe and register
callbacks to its associated `Potential`.

Each call to `invest` issues a unique `Interest`. A retain count of `Interest`s
issued is tracked by the owning `Potential`. If an `Interest` holder “loses
interest” in a `Potential` before the fate of that `Potential`’s resolution is
determined, it may `divest` its `Interest`, which causes the owning `Potential`
to disregard and dispose of all callbacks previously registered to it via the
divested `Interest`.

Cancellation is a strictly automated event. There is no available “cancel”
method; a still-`pending` `Potential` is only `canceled` upon determination
that all previously `invest`ed entities have since `divest`ed their `Interest`s
in the `Potential`’s eventual resolution.

The `canceled` state is meant to express *conclusive incompletion*, and the
ultimate product of *indifference* — from this it follows that `canceled` is
distinct from, and thus *not* intrinsically a substate of the `rejected` state.
However, non-vested consumers may of their own accord react to cancellation of
a `Potential` by `reject`ing an outer reactive `Deferral` or similar.


    class Potential extends Deferral


### Constructor

      constructor: ->
        super

At its inception a `Potential` is “self-interested”. Implementors may choose to
issue an `Interest` to a consumer prior to `divest`ing a `Potential` of its
self-interest, thereby conferring to the collective of issued `Interest`s the
ability to later cancel their owning `Potential` once they have all `divest`ed.

        @_selfInterested = yes

Equivalent to the number of issued `Interest`s still vested, plus `1` if
`@_selfInterested` is `true`.

        @_interestCount = 1

Map of issued `Interest`s, keyed by their `id`s.

        @_interests = null

Index tables for each resolution state (`accepted`, `rejected`) that associate
currently vested `Interest`s (by their `id`) with the callbacks they registered
(by the callback’s index in the corresponding array of `@_callbacks`).

        @_interestTables = null
        # e.g. =
        #   accepted:
        #     interest0: [0,3,4]
        #     interest1: [1]
        #   rejected:
        #     interest0: [0,1]



### States

      state @::,


#### unresolved

        unresolved: state


#### unresolved.pending

          pending: state do =>

            { later } = this

Enclose a free function that instigates a resolution to the `cancelled` state.
This is `call`ed when the last `Interest` is `divest`ed.

            cancel = @resolverToState 'canceled'

##### _onceFromInterest

Accepts callback registrations from an issued `Interest`, and tracks their
indices within the `Potential`’s store of `_callbacks`.

            _onceFromInterest: ( interest, stateName, callback ) ->
              interestId = interest?.id
              return unless interestId and @_interests?[ interestId ]?
              index = @_callbacks[ stateName ]?.length
              tables = @_interestTables or = {}
              table = tables[ stateName ] or = {}
              indices = table[ interestId ] or = []
              indices.push index
              @once stateName, callback

##### invest

Returns a new `Interest` in `this` `Potential`, and increments the retain count
of `interests`. A reference holder may later `divest` its `Interest`.

If `self` is a reference to `this`, `invest` reasserts the “self-interest” of
`this`, which pegs the `_interestCount` to a minumum of `1`, thus preventing
cancellation.

            invest: ( self ) ->
              if self is this
                unless @_selfInterested
                  ++@_interestCount
                  @_selfInterested = yes
                this
              else
                ++@_interestCount
                interest = new Interest this
                interestsIssued = @_interests or = {}
                interestsIssued[ interest.id ] = interest

##### divest

Obliviates `interest` and all callbacks previously registered therefrom,
decrements the `_interestCount`, and instigates cancellation if the count has
reached `0`.

With no arguments provided, the `Potential` `divest`s its own “self-interest”,
allowing it possibly to be `canceled` later in the event that all issued
`Interest`s themselves `divest` before `this` has reached a `completed` state.

            divest: ( interest ) ->
              return unless @_interestCount

              if interest?
                interestId = interest.id
                return unless @_interests?[ interestId ]?
                @_interests[ interestId ] = null
                { _callbacks } = this
                for stateName, table of @_interestTables when table?
                  unless isArray queue = _callbacks[ stateName ]
                    queue = _callbacks[ stateName ] = []
                  else queue[ index ] ?= null for index in table[ interestId ]
              else
                return if not @_selfInterested
                @_selfInterested = no

              if --@_interestCount is 0
                @_interests = @_interestTables = null
                cancel.call this
              return

##### autodivest

Asynchronously schedules `this` `Potential` to divest its self-interest.
Interested consumers have until the end of the current turn of the event loop
to `invest`, or the `Potential` will be automatically canceled.

            autodivest: -> later => do @divest


#### resolved

> Also includes the `completed` state subtree inherited from `Deferral`.

        resolved: state 'abstract',


#### resolved.canceled

          canceled: state 'final',

##### once

            once: @invokeIff 'canceled'
