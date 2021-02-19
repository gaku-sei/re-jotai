@ocaml.doc("The set of permissions attached to an atom (read, write, read and write).
Allows for safe use of atoms.")
module Permissions = {
  type w = [#writable]

  type r = [#readable]

  type rw = [r | w]
}

type t<'value, 'access> constraint 'access = [< Permissions.rw]

@module("jotai") external make: 'value => t<'value, Permissions.rw> = "atom"

// Under the hood, get is a function that takes an atom and returns a value for this atom
type getter

@ocaml.doc(`A get function that takes a getter and an atom and returns the value contained by the atom`)
let get = (type value, get: getter, atom: t<value, [> Permissions.r]>): value =>
  Obj.magic(get, atom)

@module("jotai")
external makeDerived: (getter => 'derivedValue) => t<'derivedValue, Permissions.r> = "atom"

@module("jotai")
external makeAsynDerived: (getter => Js.Promise.t<'derivedValue>) => t<
  'derivedValue,
  Permissions.r,
> = "atom"
