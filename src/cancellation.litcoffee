## Cancellation

A **cancellation** is a `Potential` that is both initialized and inherently
finalized to its `canceled` state, effectively equivalent to an immediately
divested proper `Potential`.

See also: `Acceptance`, `Rejection`

    class Cancellation extends Potential


### Constructor

Takes a value, or array of `values`, to be permanently enclosed by `this`
divested and finalized `Potential`.

      constructor: ( values ) ->
        super
        @_selfInterested = no
        @_interestCount = 0
        @_values = if isArray values then values.slice() else [values]



### States

      state @::, resolved: canceled: state 'initial final'
