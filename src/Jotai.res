type w = [#writable]

type r = [#readable]

type rw = [r | w]

type atom<'value, 'access> constraint 'access = [< rw]

@module("jotai") external atom: 'value => atom<'value, rw> = "atom"

// Under the hood, get is a function that takes an atom and returns a value for this atom
type getter

@ocaml.doc(`A get function that takes a getter and an atom and returns the value contained by the atom`)
let get = (type value, get: getter, atom: atom<value, [> r]>): value => Obj.magic(get, atom)

@module("jotai")
external derivedAtom: (getter => 'derivedValue) => atom<'derivedValue, r> = "atom"

@module("jotai")
external derivedAsyncAtom: (getter => Js.Promise.t<'derivedValue>) => atom<'derivedValue, r> =
  "atom"

@module("jotai")
external useAtom: atom<'value, rw> => ('value, ('value => 'value) => unit) = "useAtom"

@module("jotai") @deprecated("Use useDerivedAtom instead")
external useDerivedAtomInternal: atom<'value, [> r]> => ('value, unit) = "useAtom"

let useDerivedAtom = atom => {
  let (value, ()) = @ocaml.warning("-3") useDerivedAtomInternal(atom)

  value
}

module Provider = {
  @module("jotai") @react.component
  external make: (~children: React.element) => React.element = "Provider"
}
