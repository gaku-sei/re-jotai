@ocaml.doc("Use a readable _and_ writable atom.

_To prevent any mistake you can't use this hook with readonly derived atom_

```rescript
let (counter, setCounter) = Jotai.Hooks.use(counterAtom)
```
")
let use: Atom.t<'value, 'setValue, Atom.Permissions.rw> => ('value, 'setValue => unit)

@ocaml.doc("Can be used only on readable atoms. Returns only the value, no setter

```rescript
let doubleCounter = Jotai.Hook.useReadable(doubleCounterDerivedAtom)
```
")
let useReadable: Jotai.Atom.t<'value, 'setValue, [> Jotai.Atom.Permissions.r]> => 'value

@ocaml.doc("Can be used only with writable atoms. Returns only the setter, no value

```rescript
let setCounter = Jotai.Hook.useWritable(counterAtom)
```
")
let useWritable: (Jotai.Atom.t<'value, 'setValue, [> Jotai.Atom.Permissions.w]>, 'setValue) => unit
